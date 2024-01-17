import pandas as pd

# Загрузка данных из файла Excel в датафрейм
df_sales = pd.read_excel('https://github.com/IgorGorbunov/polyanalitika-sql-assignment/raw/master/%D0%98%D1%81%D1%85%D0%BE%D0%B4%D0%BD%D1%8B%D0%B5%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5.xlsx', sheet_name='Продажи' )
df_sales.to_csv('/home/sales.csv', index=False, encoding='utf-8-sig')

df_item = pd.read_excel('https://github.com/IgorGorbunov/polyanalitika-sql-assignment/raw/master/%D0%98%D1%81%D1%85%D0%BE%D0%B4%D0%BD%D1%8B%D0%B5%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5.xlsx', sheet_name='Товары' )
df_item.to_csv('/home/item.csv', index=False, encoding='utf-8-sig')

df_service = pd.read_excel('https://github.com/IgorGorbunov/polyanalitika-sql-assignment/raw/master/%D0%98%D1%81%D1%85%D0%BE%D0%B4%D0%BD%D1%8B%D0%B5%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5.xlsx', sheet_name='Услуги' )
df_service.to_csv('/home/service.csv', index=False, encoding='utf-8-sig')

df_salesman = pd.read_excel('https://github.com/IgorGorbunov/polyanalitika-sql-assignment/raw/master/%D0%98%D1%81%D1%85%D0%BE%D0%B4%D0%BD%D1%8B%D0%B5%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5.xlsx', sheet_name='Продавцы' )
df_salesman.to_csv('/home/salesman.csv', index=False, encoding='utf-8-sig')

df_department = pd.read_excel('https://github.com/IgorGorbunov/polyanalitika-sql-assignment/raw/master/%D0%98%D1%81%D1%85%D0%BE%D0%B4%D0%BD%D1%8B%D0%B5%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5.xlsx', sheet_name='Отделы' )
df_department.to_csv('/home/department.csv', index=False, encoding='utf-8-sig')

# Отображение первых нескольких строк датафрейма для проверки
df_sales.head(5)