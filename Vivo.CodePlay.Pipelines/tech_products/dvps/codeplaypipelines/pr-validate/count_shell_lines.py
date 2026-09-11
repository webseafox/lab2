#!/usr/bin/env python3
import yaml
import sys
import os

SHELL_FIELDS = {"script", "bash", "sh"}
TOTAL_LINES = 0
MAX_LINES = 50
EXTRACTED_SCRIPTS = []

def count_lines_in_shell_blocks(data):
    global TOTAL_LINES, EXTRACTED_SCRIPTS
    if isinstance(data, dict):
        for key, value in data.items():
            if key in SHELL_FIELDS and isinstance(value, str):
                line_count = len(value.strip().splitlines())
                TOTAL_LINES += line_count
                cleaned = value.strip()
                EXTRACTED_SCRIPTS.append(cleaned)
            else:
                count_lines_in_shell_blocks(value)
    elif isinstance(data, list):
        for item in data:
            count_lines_in_shell_blocks(item)

def save_extracted_scripts(output_file):
    if not EXTRACTED_SCRIPTS:
        return
    with open(output_file, "w", encoding="utf-8") as f:
        for i, script in enumerate(EXTRACTED_SCRIPTS, 1):
            f.write(f"# Script {i}\n{script}\n\n")

def main(file_path):
    global TOTAL_LINES
    if not os.path.exists(file_path):
        print(f"❌ Arquivo não encontrado: {file_path}")
        sys.exit(1)

    try:
        with open(file_path, "r") as f:
            yaml_data = yaml.safe_load(f)
        count_lines_in_shell_blocks(yaml_data)
        print(f"{file_path} contém {TOTAL_LINES} linhas de shell script nos blocos ({', '.join(SHELL_FIELDS)}).")
        save_extracted_scripts("scripts_extraidos.sh")

        if TOTAL_LINES > MAX_LINES:
            print("Excedeu o limite de {MAX_LINES} linhas.")
            #sys.exit(1)
        else:
            print("✅ Dentro do limite de linhas.")
    except Exception as e:
        print(f"Erro ao processar {file_path}: {e}")
        #sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python count_shell_lines.py <arquivo_yaml>")
        sys.exit(1)
    main(sys.argv[1])