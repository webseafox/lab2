# ==================================================================
# Makefile para validação de pipelines do CodePlay Framework
# ==================================================================
# Este Makefile facilita a utilização do pipeline-validator
# Uma libraria Python que valida pipelines CI/CD do CodePlay Framework
# Checa conformidade com as melhores práticas definidas pelo CodePlay
# ==================================================================

# Variáveis de configuração
PYTHON := python3
PIP := $(PYTHON) -m pip
POETRY := poetry
PYTEST := pytest

# Configurações do Azure Artifacts (baseadas no pipeline)
AZURE_ORG := telefonica-vivo-brasil
FEED_NAME := DevOps
PYPI_INDEX_URL := https://$(AZURE_DEVOPS_PAT)@pkgs.dev.azure.com/$(AZURE_ORG)/_packaging/$(FEED_NAME)/pypi/simple/

PIPELINE_VALIDATOR_VERSION := 0.1.17


# Cores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Função para verificar ambiente virtual
define check_venv
	@if [ ! -d ".venv" ]; then \
		echo "$(RED)⚠ Ambiente virtual não encontrado. Execute 'make setup-venv' primeiro$(NC)"; \
		exit 1; \
	fi
endef

.PHONY: help setup-venv install clean-venv venv-status activate setup

# ==================================================================
# Help - Mostra comandos disponíveis
# ==================================================================
help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)Makefile para Desenvolvimento Python com Azure Artifacts$(NC)"
	@echo ""
	@echo "$(YELLOW)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Configuração do Azure Artifacts:$(NC)"
	@echo "  Organização: $(AZURE_ORG)"
	@echo "  Feed: $(FEED_NAME)"
	@echo "  URL: $(PYPI_INDEX_URL)"

# ==================================================================
# Setup e Instalação
# ==================================================================
setup-azure: ## Configura autenticação com Azure Artifacts
	@echo "$(BLUE)Configurando Azure Artifacts...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install artifacts-keyring keyring
	@echo "$(GREEN)✓ artifacts-keyring instalado$(NC)"
	@echo "$(YELLOW)Nota: Você pode precisar fazer login no Azure CLI: az login$(NC)"

setup-venv: ## Cria e configura ambiente virtual completo
	@echo "$(BLUE)Configurando ambiente virtual...$(NC)"
	@if [ -d ".venv" ]; then \
		echo "$(YELLOW)⚠ Ambiente virtual já existe. Se quiser recriá-lo, use 'make clean-venv'$(NC)"; \
		exit 0; \
	fi
	@echo "$(BLUE)Criando novo ambiente virtual...$(NC)"
	$(PYTHON) -m venv .venv
	@echo "$(BLUE)Ativando ambiente virtual e atualizando pip...$(NC)"
	@echo "$(GREEN)✓ Ambiente virtual criado e configurado em ./.venv$(NC)"
	$(MAKE) activate

install: ## Instala dependências do projeto usando ambiente virtual
	@echo "$(BLUE)Instalando dependências do projeto...$(NC)"
	$(check_venv)
	@echo "$(BLUE)Usando Python do ambiente virtual: .venv/bin/python$(NC)"
	@.venv/bin/python --version
	@echo "$(BLUE)Instalando dependências...$(NC)"
	@if [ -z "$(AZURE_DEVOPS_PAT)" ]; then \
		echo "$(RED)✗ Variável de ambiente AZURE_DEVOPS_PAT não definida. Defina-a para autenticação no Azure Artifacts$(NC)"; \
		exit 1; \
	fi
	@.venv/bin/pip install --extra-index-url $(PYPI_INDEX_URL)  vivo-codeplay-pipeline-validator==$(PIPELINE_VALIDATOR_VERSION)
	@echo "$(GREEN)✓ vivo-codeplay-pipeline-validator instalado no ambiente virtual$(NC)"

clean-venv: ## Remove o ambiente virtual
	@echo "$(BLUE)Removendo ambiente virtual...$(NC)"
	@if [ -d ".venv" ]; then \
		rm -rf .venv; \
		echo "$(GREEN)✓ Ambiente virtual removido$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Nenhum ambiente virtual encontrado$(NC)"; \
	fi

venv-status: ## Verifica o status do ambiente virtual
	@echo "$(BLUE)Status do Ambiente Virtual:$(NC)"
	@if [ -d ".venv" ]; then \
		echo "$(GREEN)✓ Ambiente virtual existe em ./.venv$(NC)"; \
		echo "$(BLUE)Versão do Python:$(NC)"; \
		.venv/bin/python --version; \
		echo "$(BLUE)Pip instalado:$(NC)"; \
		.venv/bin/pip --version; \
		echo "$(BLUE)Pacotes instalados:$(NC)"; \
		.venv/bin/pip list; \
	else \
		echo "$(RED)✗ Ambiente virtual não encontrado$(NC)"; \
		echo "$(YELLOW)Execute 'make setup-venv' para criar$(NC)"; \
	fi

setup-complete: setup-venv install ## Setup completo do ambiente de desenvolvimento
	@echo "$(GREEN)🎉 Setup completo finalizado!$(NC)"
	@echo "$(YELLOW)Para começar a trabalhar:$(NC)"
	@echo "  1. $(BLUE)source .venv/bin/activate$(NC)"
	@echo "  2. $(BLUE)python --version$(NC) (para verificar)"
	@echo "  3. $(BLUE)pipeline-validator --help$(NC) (para ver opções do validador)"

activate: ## Mostra comando para ativar o ambiente virtual
	@echo "$(YELLOW)Para ativar o ambiente virtual, execute:$(NC)"
	@echo "$(BLUE)source .venv/bin/activate$(NC)"
	@echo ""
	@echo "$(YELLOW)Ou use o comando abreviado:$(NC)"
	@echo "$(BLUE). .venv/bin/activate$(NC)"
	@echo ""
	@echo "$(YELLOW)Para desativar depois:$(NC)"
	@echo "$(BLUE)deactivate$(NC)"

# ==================================================================
# Validação de Pipelines
# ==================================================================

# Variáveis para argumentos opcionais
ARGS ?=
CI_DIR ?=
CD_DIR ?=
POLICIES ?=
OUTPUT_DIR ?=
FORMAT ?=

validate: ## Executa validador com argumentos personalizados (ex: make validate ARGS="--ci-only --verbose")
	@echo "$(BLUE)Executando validação de pipelines com argumentos: $(ARGS)$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator $(ARGS)

validate-pipelines: ## Executa validação de pipelines CI/CD
	@echo "$(BLUE)Executando validação de pipelines...$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator

validate-ci: ## Valida apenas pipelines CI
	@echo "$(BLUE)Executando validação de pipelines CI...$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator --ci-only

validate-cd: ## Valida apenas pipelines CD
	@echo "$(BLUE)Executando validação de pipelines CD...$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator --cd-only

validate-custom: ## Validação com parâmetros customizados (ex: make validate-custom CI_DIR=custom/ci FORMAT=json)
	@echo "$(BLUE)Executando validação customizada...$(NC)"
	$(check_venv)
	@cmd=".venv/bin/pipeline-validator"; \
	if [ "$(CI_DIR)" != "" ]; then cmd="$$cmd --ci-dir $(CI_DIR)"; fi; \
	if [ "$(CD_DIR)" != "" ]; then cmd="$$cmd --cd-dir $(CD_DIR)"; fi; \
	if [ "$(POLICIES)" != "" ]; then cmd="$$cmd --policies $(POLICIES)"; fi; \
	if [ "$(OUTPUT_DIR)" != "" ]; then cmd="$$cmd --output-dir $(OUTPUT_DIR)"; fi; \
	if [ "$(FORMAT)" != "" ]; then cmd="$$cmd --format $(FORMAT)"; fi; \
	if [ "$(PIPELINE)" != "" ]; then cmd="$$cmd --pipeline $(PIPELINE)"; fi; \
	if [ "$(MATRIX)" = "true" ] || [ "$(MATRIX)" = "1" ]; then cmd="$$cmd --matrix"; fi; \
	echo "$(YELLOW)Executando: $$cmd$(NC)"; \
	eval $$cmd

validate-run: ## Executa pipeline-validator diretamente (use: make validate-run -- --help)
	@echo "$(BLUE)Executando pipeline-validator...$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator $(filter-out $@,$(MAKECMDGOALS))

validate-list: ## Lista políticas disponíveis do validador de pipelines
	@echo "$(BLUE)Listando políticas do validador de pipelines...$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator --list-policies

validate-help: ## Mostra ajuda do validador de pipelines
	@echo "$(BLUE)Opções do validador de pipelines:$(NC)"
	$(check_venv)
	@.venv/bin/pipeline-validator --help
	@echo ""
	@echo "$(YELLOW)Exemplos de uso com Make:$(NC)"
	@echo "$(GREEN)Opção 1 - Variável ARGS:$(NC)"
	@echo "  make validate ARGS=\"--help\""
	@echo "  make validate ARGS=\"--ci-only --verbose\""
	@echo "  make validate ARGS=\"--format json --output-dir reports\""
	@echo ""
	@echo "$(GREEN)Opção 2 - Argumentos diretos:$(NC)"
	@echo "  make validate-run -- --help"
	@echo "  make validate-run -- --ci-only --verbose"
	@echo "  make validate-run -- --format json"
	@echo ""
	@echo "$(GREEN)Opção 3 - Variáveis nomeadas (validate-custom):$(NC)"
	@echo "  make validate-custom FORMAT=json OUTPUT_DIR=reports"
	@echo "  make validate-custom CI_DIR=custom/ci CD_DIR=custom/cd"
	@echo "  make validate-custom POLICIES=config/custom.yaml FORMAT=markdown"
	@echo "  make validate-custom PIPELINE=framework/pipelines/ci/build-helm/pipeline.yaml"
	@echo "  make validate-custom PIPELINE=framework/pipelines/ci/build-java-docker/pipeline.yaml"
	@echo "  make validate-custom PIPELINE=framework/pipelines/ci/build-helm/pipeline.yaml MATRIX=true"
	@echo ""
	@echo "$(GREEN)Opção 4 - Comandos específicos:$(NC)"
	@echo "  make validate-ci      # Apenas pipelines CI"
	@echo "  make validate-cd      # Apenas pipelines CD"
	@echo "  make validate-pipelines  # CI e CD padrão"
	@echo ""
	@echo "$(GREEN)Opção 5 - Executar diretamente:$(NC)"
	@echo "  .venv/bin/pipeline-validator --help"

# Default target
.DEFAULT_GOAL := help

# Regra especial para tratar argumentos não reconhecidos (usado pelo validate-run)
%:
	@: