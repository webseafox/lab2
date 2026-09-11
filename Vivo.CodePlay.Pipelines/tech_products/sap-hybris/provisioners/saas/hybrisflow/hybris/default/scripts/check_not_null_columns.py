import os
import xml.etree.ElementTree as ET
from difflib import unified_diff
import subprocess

# Função para extrair as colunas e seus atributos de um XML
def extract_columns_from_xml(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    columns = []

    for itemtype in root.findall(".//itemtype"):
        for attribute in itemtype.findall(".//attribute"):
            qualifier = attribute.get('qualifier')
            optional = attribute.find('modifiers').get('optional')
            columns.append({
                'qualifier': qualifier,
                'optional': optional
            })

    return columns

# Função para obter o conteúdo do arquivo em um commit específico
def get_file_content_at_commit(file_path, commit):
    command = f"git show {commit}:{file_path}"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    return result.stdout

# Caminho dos arquivos XML no repositório
xml_files_pattern = '**/vivob2b2/**/*-items.xml'

# Caminho atual do repositório
current_directory = os.getcwd()

# Último commit
current_commit = subprocess.run("git rev-parse HEAD", shell=True, capture_output=True, text=True).stdout.strip()

# Commit anterior
previous_commit = subprocess.run("git rev-parse HEAD^", shell=True, capture_output=True, text=True).stdout.strip()

# Processar cada arquivo XML correspondente ao padrão
for root, dirs, files in os.walk(current_directory):
    for file in files:
        if file.endswith("-items.xml"):
            file_path = os.path.join(root, file)
            relative_path = os.path.relpath(file_path, current_directory)

            # Conteúdo do arquivo no commit atual e anterior
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as file:
                current_content = file.read()
            previous_content = get_file_content_at_commit(relative_path, previous_commit)

            # Gerar diff entre as versões do arquivo
            diff = list(unified_diff(previous_content.splitlines(), current_content.splitlines()))

            # Se houver diferença, analisar as colunas
            if diff:
                current_columns = extract_columns_from_xml(file_path)
                previous_columns = extract_columns_from_xml(previous_content)

                new_columns = [col for col in current_columns if col not in previous_columns]

                # Verificar se alguma nova coluna é NOT NULL
                for column in new_columns:
                    if column['optional'] == 'false':
                        print(f"Erro: Nova coluna '{column['qualifier']}' é NOT NULL no arquivo {file_path}")
                        exit(1)

print("Nenhuma nova coluna NOT NULL encontrada.")
