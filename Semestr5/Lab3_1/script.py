import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta
from tqdm import tqdm
from pathlib import Path
import json

# Инициализируем Faker для генерации случайных данных
path = 'data_new/'
fake = Faker()
tqdm.pandas()
# Шаг 1: Загрузить данные из CSV для dim_locations
def get_locations():
    return pd.read_csv('data/city.csv', delimiter=',')
def get_users(num=1_000_000):
    # Шаг 2: Создание таблицы dim_users
    file_path = Path(path + 'dim_users.csv')
    if not file_path.exists(): 
        print("Генерируем данные пользователей")
        users = []
        for i in tqdm(range(num), desc='users'):  # Генерируем 100 пользователей
            user = {
                "user_id": i + 1,
                "name": fake.name(),
                "age": random.randint(18, 65),
                "gender": random.choice(["Male", "Female"])
            }
            users.append(user)
 
        dim_users = pd.DataFrame(users)
        dim_users.to_csv(path + 'dim_users.csv', index=False)
    else:
        print("Данные уже существуют загружаем")
        dim_users = pd.read_csv(file_path)
    return dim_users

# Шаг 3: Создание таблицы dim_stores
def get_stores(num=1_000_000):
    stores = []
    file_path = Path(path + 'dim_stores.csv')
    if not file_path.exists():
        print("Генерируем данные")
        length = len(dim_locations)
        for i in tqdm(range(num), desc="stores"):  # Генерируем 50 магазинов
            #city = dim_locations.sample(n=1).iloc[0]
            city = dim_locations.iloc[i % len(dim_locations)]
            store = {
                "store_id": i + 1,
                "name": fake.company(),
                "country": city["country"],
                "region": city["region"],
                "city": city["city"],
                "latitude": city["geo_lat"],
                "longitude": city["geo_lon"],
                "contact_info": json.dumps({
                    "phone": fake.phone_number(),
                    "email": fake.email(),
                    "website": fake.url()
                })
            }
            stores.append(store)

        dim_stores = pd.DataFrame(stores)
        dim_stores.to_csv(path + 'dim_stores.csv', index=False)
    else: 
        print("Данные уже существуют загружаем")
        dim_stores = pd.read_csv(file_path)
    return dim_stores

# Шаг 4: Создание таблицы dim_products
def get_products(num=1_000_000):
    file_path = Path(path + 'dim_products.csv')
    if not file_path.exists():
        print("Генерируем данные")
        products = []
        categories = ["Electronics", "Clothing", "Groceries", "Books", "Toys"]
        for i in tqdm(range(num), desc="products"):  # Генерируем 200 продуктов
            product = {
                "product_id": i + 1,
                "name": fake.word(),
                "category": random.choice(categories),
                "price": round(random.uniform(5.0, 5000.0), 2)  # Случайная цена
            }
            products.append(product)

        dim_products = pd.DataFrame(products)
        dim_products.to_csv(path + 'dim_products.csv', index=False)
    else: 
        print("Данные уже существуют загружаем")
        dim_products = pd.read_csv(file_path)
    return dim_products


def get_time():
# Шаг 5: Создание таблицы dim_time
    file_path = Path(path + 'dim_time.csv')
    if not file_path.exists():
        print("Генерируем данные")
        start_year = 1991
        end_year = 2024
        time_data = []
        time_id = 1
        month_names = [
        "January", "February", "March", "April", "May", "June", 
        "July", "August", "September", "October", "November", "December"]
        for year in tqdm(range(start_year, end_year + 1), desc=f"Year"):
            for month in range(1, 13):  # Месяцы от 1 до 12
                month_code = f"{month:02d}"  # Делаем месяц в формате "01", "02" и т.д.
                month_name = month_names[month - 1]  # Название месяца
                time_data.append({
                    "time_id": time_id,
                    "month_code": month_code,
                    "month_name": month_name,
                    "year": year
                })
                time_id += 1

        dim_time = pd.DataFrame(time_data)
        dim_time.to_csv(path + 'dim_time.csv', index=False)
    else: 
        print("Данные уже существуют загружаем")
        dim_time = pd.read_csv(file_path)
    return dim_time
# Шаг 6: Создание таблицы sales_facts
def get_facts(num=100_000_000, dim_num=1_000_000):
    file_path = Path(path + 'sales_facts.csv')
    if not file_path.exists():
        print("Генерируем данные")
        sales = []
        for i in range(num):  # Генерируем 1000 записей о продажах
            sale = {
                "fact_id": i + 1,
                "product_id": random.randint(1, dim_num),
                "time_id": random.randint(1, len(dim_time)),
                "store_id": random.randint(1, dim_num),
                "quantity": random.randint(1, 100),
                "user_id": random.randint(1, dim_num),
                "total_amount": None,
            }
            sales.append(sale)

        sales_facts = pd.DataFrame(sales)
        sales_facts.to_csv('sales_facts.csv', index=False)







def batched_get_stores(batch_size=10_000, num=1_000_000):
    file_path = Path(path + 'dim_stores.csv')

    if not file_path.exists():
        print("Генерируем данные")

        # Открываем файл в режиме записи
        with open(file_path, 'w', encoding='utf-8') as f:
            # Записываем заголовки столбцов
            f.write("store_id,name,country,region,city,latitude,longitude\n")
            f.flush()

            for batch_start in tqdm(range(0, num, batch_size), desc="stores"):
                stores = []
                batch_end = min(batch_start + batch_size, num)
                
                for i in range(batch_start, batch_end):
                    #city = dim_locations.sample(n=1).iloc[0]
                    city = dim_locations.iloc[i % len(dim_locations)]
                    store = {
                        "store_id": i + 1,
                        "name": fake.company(),
                        "country": city["country"],
                        "region": city["region"],
                        "city": city["city"],
                        "latitude": city["geo_lat"],
                        "longitude": city["geo_lon"],
                        "contact_info": json.dumps({
                            "phone": fake.phone_number(),
                            "email": fake.email(),
                            "website": fake.url()
                })
            }
                    stores.append(store)

                # Преобразуем батч в DataFrame и записываем в файл
                dim_stores_batch = pd.DataFrame(stores)
                dim_stores_batch.to_csv(f, header=False, index=False, mode='a', encoding='utf-8')

    else:
        print("Данные уже существуют, загружаем")
        dim_stores = pd.read_csv(file_path)
        return dim_stores

    # Читаем данные после завершения генерации
    dim_stores = pd.read_csv(file_path)
    return dim_stores











def batched_get_facts(batch_size=10_000, num=100_000_000, dim_num=1_000_000, file_path='sales_facts.csv'):
    file_path = Path(path + 'sales_facts.csv')
    
    # Проверяем, существует ли файл
    if not file_path.exists():
        print("Генерируем данные")
        sales = []
        
        # Инициализируем записи и пишем в файл по батчам
        with open(file_path, 'w', newline='') as f:
            # Пишем заголовки в файл
            f.write('fact_id,product_id,time_id,store_id,quantity,user_id,total_amount\n')
            f.flush()
            for i in tqdm(range(0, num, batch_size), desc="Генерация данных", unit="батч"):
                batch = []
                for j in range(batch_size):
                    fact_id = i + j + 1
                    sale = {
                        "fact_id": fact_id,
                        "product_id": random.randint(1, dim_num),
                        "time_id": random.randint(1, len(dim_time)),
                        "store_id": random.randint(1, dim_num),
                        "quantity": random.randint(1, 100),
                        "user_id": random.randint(1, dim_num),
                        "total_amount": 0, 
                    }

                    batch.append(sale)
                # Записываем текущий батч в файл
                batch_df = pd.DataFrame(batch)
                batch_df.to_csv(file_path, mode='a', header=False, index=False)
                
                # Очистка батча после записи
                batch.clear()
                
        print(f"Данные успешно сгенерированы и записаны в файл {file_path}")
    else: 
        print(f"Данные уже сгенерированы")

dim_num = 20_000
fact_num = 100_000

dim_locations = get_locations()
batched_get_stores(batch_size=5_000, num=dim_num)
get_users(num=dim_num)
get_products(num=dim_num)
dim_time = get_time()

batched_get_facts(num=fact_num, batch_size=10_000, dim_num=dim_num)





print("Все таблицы сгенерированы и сохранены в CSV файлы!")
