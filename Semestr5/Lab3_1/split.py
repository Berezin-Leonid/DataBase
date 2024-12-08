import pandas as pd

# Загрузите CSV файл
file_path = 'data/sales_facts.csv'
df = pd.read_csv(file_path)

# Определите количество строк в файле
total_rows = len(df)

# Определите количество строк в каждом куске
rows_per_chunk = total_rows // 100

# Разбейте DataFrame на 100 кусков
chunks = [df[i * rows_per_chunk:(i + 1) * rows_per_chunk] for i in range(100)]

# Сохраните каждый кусок в отдельный CSV файл
for i, chunk in enumerate(chunks):
    print(f'Saving {i + 1}')
    chunk.to_csv(f'data_chunk/chunk_{i + 1}.csv', index=False)

print("Файл успешно разбит на 100 кусков.")
