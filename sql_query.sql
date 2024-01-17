-- Продажи только с актуальными ценами. Объединение товаров и услуг
-- Добавлены колонки: цена по каталогу, наименование,  наценка, процент наценки
DROP MATERIALIZED VIEW IF EXISTS only_act_sell_prices CASCADE;

CREATE MATERIALIZED VIEW only_act_sell_prices AS
SELECT sales.*,
       item_and_service.price,
       item_and_service.name,
       sales.final_price / sales.quantity - item_and_service.price AS price_overcharge,
       round( (sales.final_price / sales.quantity - item_and_service.price) / cast(item_and_service.price AS numeric) * 100, 2 ) AS price_overcharge_percent
FROM grigoryev.stg_sales AS sales
INNER JOIN
  (
 SELECT *
   FROM grigoryev.stg_item WHERE is_actual = 1
   union SELECT *
   FROM grigoryev.stg_service WHERE is_actual = 1 ) 
   AS item_and_service ON sales.item_id = item_and_service.id
   AND (sales.sale_date between item_and_service.sdate AND item_and_service.edate);

SELECT * FROM only_act_sell_prices;


-- Агрегация продаж по сотрудникам за неделю
DROP MATERIALIZED VIEW if exists week_period_agg CASCADE;

CREATE MATERIALIZED VIEW week_period_agg AS
SELECT 'week' AS period_type,
       week_interval.first_date AS start_date,
       date ( week_interval.first_date + interval '6 day' ) AS end_date,
       salesman_id,
       COUNT(week_interval.final_price) AS sales_count,
       SUM(week_interval.final_price) AS sales_sum,
       MAX(price_overcharge) AS max_overcharge,
       MAX(price_overcharge_percent) AS max_overcharge_percent
FROM
  ( SELECT *,
           date (date_trunc ('week', sale_date)) AS first_date
   FROM only_act_sell_prices ) AS week_interval
GROUP BY salesman_id, first_date;

SELECT * FROM week_period_agg;


-- Агрегация продаж по сотрудникам за месяц
DROP MATERIALIZED VIEW IF EXISTS month_period_agg CASCADE;

CREATE MATERIALIZED VIEW month_period_agg AS
SELECT 'month' AS period_type,
       month_interval.first_date AS start_date,
       date ( month_interval.first_date + interval '1 month' - interval '1 day' ) AS end_date,
       salesman_id,
       COUNT(month_interval.final_price) AS sales_count,
       SUM(month_interval.final_price) AS sales_sum,
       MAX(price_overcharge) AS max_overcharge,
       MAX(price_overcharge_percent) AS max_overcharge_percent
FROM
  ( SELECT *,
       date (date_trunc ('month', sale_date)) AS first_date
   FROM only_act_sell_prices ) AS month_interval
GROUP BY salesman_id, first_date;

SELECT * FROM month_period_agg;


-- Добавлен товар или услуга с наибольшей наценкой за неделю
DROP MATERIALIZED VIEW IF EXISTS top_items_week CASCADE;

CREATE MATERIALIZED VIEW top_items_week AS
SELECT distinct 
        t.period_type, 
        t.start_date,
        t.end_date,
        t.salesman_id,
        t.sales_count,
        t.sales_sum,
        t.max_overcharge,
        t.max_overcharge_percent,
        tt.name AS max_overcharge_item
FROM week_period_agg AS t
inner JOIN only_act_sell_prices AS tt 
 ON t.max_overcharge = tt.price_overcharge
AND ( tt.sale_date between t.start_date AND t.end_date );

SELECT * FROM top_items_week;


-- Добавлен товар или услуга с наибольшей наценкой за месяц
DROP MATERIALIZED VIEW IF EXISTS top_items_month CASCADE;

CREATE MATERIALIZED VIEW top_items_month AS
SELECT distinct t.period_type,
                t.start_date,
                t.end_date,
                t.salesman_id,
                t.sales_count,
                t.sales_sum,
                t.max_overcharge,
                t.max_overcharge_percent,
                tt.name AS max_overcharge_item
FROM month_period_agg AS t
join only_act_sell_prices AS tt ON t.max_overcharge = tt.price_overcharge
AND ( tt.sale_date between t.start_date AND t.end_date );

SELECT * FROM top_items_month;


-- Объеднение периодов
DROP MATERIALIZED VIEW IF EXISTS month_and_week_periods_agg CASCADE;

CREATE MATERIALIZED VIEW month_and_week_periods_agg AS
SELECT *
FROM top_items_week
union
SELECT *
FROM top_items_month;

SELECT * FROM month_and_week_periods_agg;


-- Добавление ФИО и департамента продавца
DROP MATERIALIZED VIEW IF EXISTS periods_and_salesmans_fio CASCADE;

CREATE MATERIALIZED VIEW periods_and_salesmans_fio AS
  ( SELECT main.*,
           f.fio AS salesman_fio,
           f.department_id AS sales_department_id
   FROM grigoryev.stg_salesman AS f
   inner join month_and_week_periods_agg AS main ON main.salesman_id = f.id );

SELECT * FROM periods_and_salesmans_fio;



-- Добавление ФИО и департамента руководителя
DROP MATERIALIZED VIEW IF EXISTS periods_and_chifs_fio CASCADE;

CREATE MATERIALIZED VIEW periods_and_chifs_fio AS
  ( SELECT main.*,
           fio AS chif_fio
   FROM
     ( SELECT main.*,
              dep_chif_id
      FROM stg_department AS d
      left join periods_and_salesmans_fio AS main 
	  ON d.department_id = main.sales_department_id ) AS main
   left join stg_salesman AS s 
   ON s.id = main.dep_chif_id
   where salesman_fio is not null );

SELECT * FROM periods_and_chifs_fio;


-- Итоговый запрос с сортировкой
SELECT period_type,
       start_date,
       end_date,
       salesman_fio,
       chif_fio,
       sales_count,
       sales_sum,
       max_overcharge_item,
       max_overcharge_percent
FROM periods_and_chifs_fio
order by salesman_fio, start_date;