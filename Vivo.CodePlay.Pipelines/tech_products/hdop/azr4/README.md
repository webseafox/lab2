# 4P Core Pipelines 

Esse framework foi desenvolvido para facilitar a migração DevOps 4p -> DevOps Corp.

## Estrutura de diretórios

- **pipelines**: diretório onde ficam os arquivos de entrypoint de pipelines. Ele funciona como uma casca que implementa as receitas de execução de pipelines, garantindo que a execução de pipelines seja feita de forma padronizada.
- **recipes**: diretório onde ficam os arquivos de receitas de execução de pipelines. Cada arquivo de receita é responsável por implementar a execução de um pipeline para técnologias específicas e de naturezas diferentes (Build, Deploy...).
- **templates**: diretório onde ficam os arquivos de templates:
  - **steps**: Templates de steps que podem ser reutilizados em diferentes receitas. Funcionam como funções que podem ser chamadas em diferentes jobs.
  - **branch_variables**: Templates utilizado para pipeline do tipo gitlabfow, são responsáveis por definir variáveis de ambiente baseado na branch de execução.

## Criando um novo pipeline:

1. Defina se o pipeline será do tipo `build` ou `deploy`. O tipo `merge_validation` importa as receita do tipo `build`e exclui alguns estagios.
2. Copie a receita de `recipes/<tipo>/example` para o diretório `recipes/<tipo>/<nome>` com o nome do pipeline que você deseja criar.
3. Edite os estágios e jobs do pipeline conforme a necessidade.

## Executando um pipeline:



## Erros conhecidos

### Não le a variável no .azuredevops/pipelines/file.yml

Quando está utilizando variavel default no modelo abaixo:

```yaml
variables:
- ${{ if not(variables['IMAGE_NAME']) }}:
  - name: IMAGE_NAME
    value: $(Build.Repository.Name)
- ${{ if not(variables['IMAGE_REGISTRY_CONNECTION']) }}:
  - name: IMAGE_REGISTRY_CONNECTION
    value: 'registry-telefonicabigdata'
```

OBRIGATORIAMENTE as variáveis devem ser definidas no pipeline, no seguinte formato:

```yaml
variables:
  IMAGE_REGISTRY_CONNECTION: 'IMAGE_REGISTRY_CONNECTION'
  IMAGE_NAME: 'IMAGE_NAME'
```
