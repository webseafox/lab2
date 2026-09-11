# Script de Execução Automatizada com Maven e Docker

Este script é projetado para automatizar a execução de testes utilizando diferentes frameworks de teste (Cucumber e JUnit) e ambientes Docker. Ele configura licenças, manipula arquivos `hosts`, sanitiza variáveis e executa comandos Maven. Além disso, faz a coleta de métricas após a execução dos testes.

## Estrutura Geral do Script

- **Controle de cores ANSI**: Utilizado para gerar saídas coloridas no terminal.
- **Exportação de variáveis de ambiente**: Configura as permissões padrão e define variáveis globais.
- **Funções de utilidade**: Para ler cenários, sanitizar variáveis, gerenciar parâmetros opcionais, e configurar frameworks.
- **Execução dos testes**: O script executa os testes em paralelo e coleta logs para cada execução.

### Estrutura de Diretórios

- O script considera que o código Java está localizado no diretório `src/main/java`.
- As pastas `.azuredevops/cenarios/` e `.azuredevops/params/` contêm arquivos com cenários e parâmetros que são lidos durante a execução.

### Variáveis Importantes

- `DOCKER_IMAGE`: Define a imagem Docker em uso (ex.: `selenium`, `selenium-v2`, `uftdeveloper`). Ver a seção *Parâmetro `docker_image`* para a lista completa.
- `SCENARIOS`: Lista de cenários que serão executados. Pode ser lido de um arquivo específico.
- `OPTIONALS`: Parâmetros opcionais adicionais, também lidos de arquivos.
- `PROJECT_ID`: Identificador do projeto para os testes.
- `FRAMEWORK`: Define qual framework será usado (ex.: `Cucumber`, `JUnit`).


---

## Parâmetros do template

Todos os parâmetros abaixo são informados dentro de `config.params`, na pipeline consumidora:

```yaml
extends:
  template: /tech_products/qa/execution/entrypoint.yml@CodePlay
  parameters:
    config:
      pipelineType: qa
      technology: java
      modelName: scenarios_default
      branchingStrategy: trunkbased
      params:
        framework: Cucumber
        cenario: "${{ parameters.cenario }}"
        optionals: "${{ parameters.optionals }}"
        docker_image: selenium
        fail_pipeline: "${{ parameters.fail_pipeline }}"
        test_environment: "${{ parameters.test_environment }}"
        maven_settings: $(pwd)/settings.xml
```

---

### `docker_image` — imagem de execução

| Alias | Imagem | Ambiente |
|-------|--------|----------|
| `selenium` | `base/qa/selenium-junit/oraclient/runtime:1.0.1` | Chrome 102, Ubuntu 18.04, Oracle Instant Client 21.7 |
| `selenium-v2` | `base/qa/selenium-junit/oraclient/runtime:2.0.0` | Chrome 151, Ubuntu 24.04, Oracle Instant Client 23.8, certificado CACORP |
| `selenium-xfcb-chrome` | `base/qa/selenium-xvfb/chrome/runtime:1.0.2` | |
| `selenium-xfcb-edge` | `base/qa/selenium-xvfb/edge/runtime:1.0.2` | |
| `selenium-xfcb-firefox` | `base/qa/selenium-xvfb/firefox/runtime:1.0.2` | |
| `uftdeveloper` | `base/qa/uftdeveloper/chrome/runtime:1.0.2` | Configura licença LeanFT |
| `windows`, `windows-selenium` | — | Roteia para o provisioner Windows |

Nas imagens Selenium o script remove a variável `DISPLAY` e adiciona `127.0.0.1` ao `/etc/hosts` — ou seja, **os testes rodam headless**.

#### Diferenças de ambiente na `selenium-v2`

Se você estiver migrando de `selenium` para `selenium-v2`, dois caminhos mudaram:

- **Oracle Instant Client**: de `/usr/lib/oracle/21/client64` para `/opt/oracle/instantclient_23_8`. As variáveis `ORACLE_HOME`, `LD_LIBRARY_PATH` e `PATH` já são exportadas pela imagem — só é preciso ajustar código que referencie o caminho fixo.
- **Java**: `JAVA_HOME` aponta para o Java 11. O Java 21 da imagem base do Selenium também está disponível.

---

### `qa_proxy` — proxy do container

Sobrescreve `HTTP_QA_PROXY` e `HTTPS_QA_PROXY`, que recebem o mesmo valor. Quando não informado, usa `proxy.redecorp.br:8080`.

```yaml
        params:
          qa_proxy: "meu-proxy.redecorp.br:3128"
```

---

### `maven_debug` — nível de log do Maven

Controla se o Maven roda com `-X` (debug) ou `-e`. **Padrão: `false`.**

```yaml
        params:
          maven_debug: true
```

| Valor | Flag | Efeito |
|-------|------|--------|
| `false` (padrão) | `-e` | Stack trace completo em caso de erro |
| `true` | `-X` | Debug completo, incluindo o despejo de todas as variáveis de ambiente do container no formato `[DEBUG] env.NOME: valor` |

O `-X` também é ativado quando a pipeline é executada com **`system.debug = true`**, útil para uma investigação pontual sem alterar o YAML. Nesse caso o script avisa no início da execução:

```
[WARNING] Maven em modo debug (-X). O log vai conter o despejo das variaveis de ambiente.
```

Valores registrados como secret saem mascarados nesse despejo; variáveis não marcadas como secret aparecem em texto puro.

---

## Variáveis de ambiente no container

Para uma variável chegar ao código de teste via `System.getenv()`, duas coisas precisam acontecer: ela precisa **existir no escopo da pipeline** e precisa ser **selecionada para atravessar** até o container.

### 1. De onde vêm as variáveis

| Caminho | Como |
|---|---|
| **Aba Variables do Azure DevOps** | Defina a variável pela interface do pipeline |
| **Parâmetro `variable_groups`** | Vincula um variable group (Library) a partir do próprio template |

```yaml
        params:
          variable_groups:
            - "MeuGrupo-Secrets-QA"
```

> ⚠️ **Não use `variables:` na raiz da pipeline consumidora.** O template alvo do `extends` já declara o próprio bloco `variables:`, e um segundo na raiz causa erro de compilação:
> ```
> __built-in-schema.yml (Line: 40, Col: 11): 'variables' is already defined
> ```
> Vale tanto para `- name/value` quanto para `- group:`.

### 2. Quais atravessam para o container

O `variable_groups` apenas **vincula** o grupo. Quem seleciona o que entra no container é o `extra_env` ou o `extra_env_names`:

| Parâmetro | Formato | Quando usar |
|---|---|---|
| `extra_env_names` | lista de nomes | O nome no container é o mesmo do pipeline — o caso da maioria |
| `extra_env` | mapa `nome_no_container: $(nome_no_pipeline)` | O nome no container precisa ser diferente |

Os dois podem ser combinados, e ambos funcionam com variáveis **secretas**.

```yaml
        params:
          variable_groups:
            - "test-library"
          extra_env_names:
            - TOKEN_AZURE_OSS
            - TOKEN_AZURE_VIVO_MAIS
          extra_env:
            API_TOKEN: $(TOKEN_BASIC_AZURE_SIRIUS)
```

No exemplo, o container recebe `TOKEN_AZURE_OSS`, `TOKEN_AZURE_VIVO_MAIS` e `API_TOKEN`.

Sem `extra_env`/`extra_env_names`, a variável existe no agente mas não entra no container, e o `System.getenv()` devolve `null`.

> Não existe um modo "repassar o grupo inteiro". Variáveis secretas nunca entram no ambiente do agente — só chegam por mapeamento explícito `$(NOME)` —, e não há como enumerá-las em tempo de compilação do YAML. Um modo automático funcionaria apenas para as não-secretas e falharia em silêncio justamente nas secretas.

### 3. Formato dos nomes

| Campo | Regra |
|-------|-------|
| Nome da variável no container | Apenas `A-Z`, `0-9` e `_`, sem iniciar com dígito. UPPER_SNAKE_CASE recomendado |
| Valor em `extra_env` | Referência `$(NOME)` a uma variável do pipeline, ou valor literal |

Nomes fora desse formato são ignorados com um warning no log.

### 4. Mascaramento no log

Todo valor com **4 caracteres ou mais** é registrado via `##vso[task.setsecret]` e aparece como `***` no log. Isso cobre o despejo de ambiente do `system.debug`, a saída do container transmitida por `docker logs -f` e qualquer echo de comando Maven.

Valores com menos de 4 caracteres não são mascarados, para evitar que algo como `"1"` ou `"true"` transforme o log inteiro em `***`.

### 5. Como funciona internamente

1. O template mapeia cada variável no bloco `env:` das tasks com o prefixo `EXTRA_VAR_`. Esse mapeamento explícito é o que torna variáveis secretas acessíveis — elas não entram no ambiente do agente automaticamente.
2. O step `Mask extra env values` roda como primeiro do job e registra os valores para mascaramento.
3. O `build_scenario.sh` percorre as variáveis `EXTRA_VAR_*`, remove o prefixo e monta as flags `-e NOME`.
4. O `docker run` usa `-e NOME` **sem valor**: o Docker herda o valor do ambiente do processo. Nenhum valor é escrito em disco nem aparece na linha de comando do `docker run`, visível via `ps` de dentro do container.

### 6. Solução de problemas

O `build_scenario.sh` emite um warning nomeando a variável quando algo dá errado:

| Warning | Causa | O que fazer |
|---------|-------|-------------|
| `a variavel 'X' nao foi resolvida` | O agente não expandiu `$(X)` — a variável não existe no escopo da pipeline | Confirme o nome. Se vier de Library, verifique se o grupo está vinculado e autorizado |
| `a variavel 'X' chegou vazia` | A variável existe mas está sem valor. É repassada mesmo assim | Verifique o valor na Library ou na aba Variables |
| `a chave 'X' nao e um nome valido` | Nome inválido para variável de ambiente | Renomeie usando apenas `A-Z`, `0-9` e `_` |

No fim do bloco o script informa quantas variáveis foram repassadas:

```
##[section]extra_env: 3 variavel(is) repassada(s) ao container (valores mascarados no log).
```

### 7. Recomendações de segurança

1. **Use Variable Groups (Library)** para valores sensíveis — nunca hardcode no YAML
2. **Marque as variáveis como secret** na Library — o Azure DevOps já as mascara nos logs
3. **Para secrets do Key Vault**, vincule a Library ao Azure Key Vault
4. Os parâmetros são **opcionais**. Pipelines que não os usam continuam funcionando normalmente

### 8. Leitura no código Java

```java
// Via -D no Maven (o valor fica visível na linha de comando):
String policy = System.getProperty("POLICY_AZURE_EVENTS_EV_REGISTER_CARD_EVENTS_IN");

// Via variável de ambiente (recomendado):
String policy = System.getenv("POLICY_AZURE_EVENTS_EV_REGISTER_CARD_EVENTS_IN");
```

---

## Funcionalidades Principais

### Configurações de Docker

Dependendo da imagem Docker especificada na variável `DOCKER_IMAGE`, o script ajusta o ambiente:

- Para imagens Selenium (`selenium`, `selenium-v2`, `selenium-xfcb-chrome`, etc.), o script remove a variável `DISPLAY` e adiciona `127.0.0.1` ao arquivo `/etc/hosts`. Ou seja, os testes rodam **headless**.
- Para imagens `uftdeveloper`, o script configura a licença e instala ferramentas relacionadas à licença LeanFT.
- O container é criado com `--shm-size=2g`. O padrão do Docker é 64 MB de `/dev/shm`, insuficiente para o Chrome moderno quando vários cenários rodam em paralelo (sintoma típico: `session deleted because of page crash`).

### Funções

- **`generate_hosts_args`**: Atualiza o arquivo `/etc/hosts` baseado em um arquivo de hosts customizado (`/scripts/hosts`).
- **`sanitize_variable`**: Remove quebras de linha, tabulações e espaços extras de uma variável.
- **`read_scenarios`**: Lê a lista de cenários de um arquivo ou diretamente da variável e prepara blocos de cenários para execução.
- **`read_optionals`**: Lê parâmetros opcionais de um arquivo ou diretamente da variável.
- **`read_projectid`**: Lê e sanitiza a lista de `PROJECT_ID` a partir de uma string separada por `|`.
- **`get_qandalf_version`**: Verifica a versão do artefato `qandalf` no `pom.xml` para definir configurações específicas de execução.
- **`handle_exit`**: Realiza tarefas de limpeza e finalização, quando  tem interrupção ou erro no processo. 
- **`unset_array`**: Limpa ou desaloca variáveis de array no shell, essa função garanti que o array seja completamente removido ou redefinido.
- **`get_memTotal`**: Retorna o valor total de memória disponível no sistema, lendo o arquivo /proc/meminfo, que contém informações detalhadas sobre a memória do sistema.
- **`get_memAvailable`**: Retorna a memória total do sistema, ou seja, a memória que está livre para uso imediato, sem precisar liberar recursos adicionais.
- **`get_memUsed`**: Calcula a quantidade de memória atualmente em uso, que é basicamente a diferença entre a memória total e a memória disponível. Aqui estamos monitorando o consumo de memória em tempo real.
- **`get_memByPID`**: Obtem a quantidade de memória usada por um processo específico com base em seu PID. Aqui estamos monitorando o consumo de memória de processos individuais.
- **`check_and_remove_finished_pids`**: Verifica os processos em execução e remove aqueles que já foram finalizados de uma lista de PIDs.
- **`monitor`**: Essa função acompanha o uso de memória e processos do sistema, coletando informações de memória e registrando PIDs que estão em execução.
- **`calc_max_memory_per_process`**: Essa função calcula a quantidade máxima de memória que cada processo pode utilizar, com base na memória total disponível e na quantidade de processos em execução.
- **`can_run_more`**: Essa função determina se mais processos podem ser iniciados com base na utilização atual da memória e nos limites estabelecidos.

### 1. generate_hosts_args

A função `generate_hosts_args` lê o arquivo `/scripts/hosts`, remove comentários e linhas em branco, e sobrescreve o conteúdo do arquivo `/etc/hosts` com as linhas filtradas.

#### Explicação detalhada:

1. **`grep -v '^\s*#' /scripts/hosts`**:
   - Lê o arquivo `/scripts/hosts` e exclui (`-v`) todas as linhas que começam (`^`) com qualquer quantidade de espaços (`\s*`) seguidos por um `#` (indicando um comentário).
   
2. **`grep -v '^\s*$'`**:
   - Remove (`-v`) as linhas que estão completamente vazias (ou seja, linhas que contêm apenas espaços ou são completamente em branco).

3. **`sudo tee /etc/hosts > /dev/null`**:
   - Usa o comando `tee` para gravar a saída filtrada diretamente no arquivo `/etc/hosts`. O uso de `sudo` é necessário para ter permissão de escrita nesse arquivo. 
   - A saída padrão é redirecionada para `/dev/null`, ou seja, a saída não será exibida no terminal.

#### Resumo:
A função processa o arquivo `/scripts/hosts`, removendo linhas de comentário e linhas vazias, e depois atualiza o arquivo `/etc/hosts` com o conteúdo filtrado.

### 2. sanitize_variable

A função `sanitize_variable` limpa uma variável de entrada removendo caracteres indesejados, como tabulações, novas linhas e retornos de carro, além de remover espaços extras nas extremidades.

#### Explicação detalhada:

1. **`echo $1`**:
   - Imprime o valor da variável de entrada `$1` no terminal. Esse valor é o argumento passado para a função.

2. **`tr -d '\t\n\r'`**:
   - O comando `tr` é usado para remover (`-d`) todos os caracteres de tabulação (`\t`), nova linha (`\n`) e retorno de carro (`\r`). Isso garante que a string resultante fique em uma única linha e sem esses caracteres especiais.

3. **`xargs`**:
   - O comando `xargs` remove os espaços em branco extras no início e no final da string, garantindo que a variável esteja "limpa" e pronta para uso sem espaços desnecessários nas extremidades.

#### Resumo:
A função `sanitize_variable` remove tabulações, quebras de linha e retornos de carro de uma string, além de eliminar espaços extras no início e no final, resultando em uma string "sanitizada".

### 3. read_scenarios

A função `read_scenarios` lê e processa cenários de teste a partir de um arquivo ou de uma string fornecida como entrada. O comportamento depende do valor do parâmetro `scenarios` passado na chamada da função:

#### 1. Entrada baseada em arquivo

Se o valor de `scenarios` começar com a palavra `"default"`, a função procura um arquivo correspondente na pasta `.azuredevops/cenarios/`. Por exemplo, se `scenarios` for `"default_tests"`, ela tentará abrir o arquivo `.azuredevops/cenarios/default_tests.txt`.

- Caso o arquivo não seja encontrado ou esteja vazio, a função exibe uma mensagem de erro e encerra a execução com código de saída `1`.
- Se o arquivo existir e tiver conteúdo, esse conteúdo será lido e usado como a lista de cenários a serem processados.

#### 2. Entrada direta como string

Se o valor de `scenarios` **não** começar com `"default"`, ele será tratado diretamente como a lista de cenários. Essa lista pode conter vários cenários separados pelo caractere `|`.

#### Processamento dos cenários

- Após definir os cenários (seja a partir de um arquivo ou diretamente), a função divide a string de cenários usando o caractere `|` como delimitador. Cada parte resultante é armazenada no array `scenarios_blocks`.
- Em seguida, a função itera sobre cada cenário dentro do array e executa a função `sanitize_variable` em cada um deles, provavelmente para ajustar ou limpar os valores antes de serem utilizados.

#### Fluxo

1. Verifica se o valor de `scenarios` começa com `"default"`.
2. Se sim, busca o arquivo de cenários correspondente, e caso o arquivo seja inválido, exibe um erro.
3. Caso contrário, ou se o arquivo for válido, os cenários são processados e tratados.
4. Cada cenário é passado pela função de sanitização.

### 4. read_optionals

A função `read_optionals` processa uma lista de parâmetros opcionais que podem ser fornecidos como uma string ou lidos a partir de um arquivo. Se o valor de entrada começar com `"default"`, a função busca o conteúdo em um arquivo específico; caso contrário, trata o valor diretamente como a lista de parâmetros.

#### Explicação detalhada:

1. **`local optionals=$1`**:
   - Armazena o primeiro argumento passado para a função na variável `optionals`. Este valor pode ser uma string de parâmetros opcionais ou uma referência a um arquivo de parâmetros.

2. **`local optionals_blocks=()`**:
   - Inicializa um array vazio `optionals_blocks`, que será usado para armazenar os parâmetros processados.

3. **`if [[ ${optionals} == "default"* ]]`**:
   - Verifica se o valor de `optionals` começa com a palavra `"default"`. Se sim, a função entende que precisa carregar os parâmetros opcionais de um arquivo.

4. **`[[ ! -s .azuredevops/params/$optionals.txt ]] && echo -e "\n ${BRed}ERROR! Params $optionals.txt file is not found." >&2 && exit 1`**:
   - Verifica se o arquivo `.azuredevops/params/$optionals.txt` existe e não está vazio. Caso contrário, exibe uma mensagem de erro no console e encerra a execução da função com código de saída `1`.

5. **`optionals=$(cat .azuredevops/params/"$optionals".txt)`**:
   - Se o arquivo for encontrado, o conteúdo dele é lido e atribuído à variável `optionals`.

6. **`IFS='|' read -ra optionals_blocks <<< "$optionals"`**:
   - A string de `optionals` é dividida em várias partes com base no delimitador `|` e armazenada no array `optionals_blocks`.

7. **`printf '%s\n' "${optionals_blocks[@]}"`**:
   - Imprime cada item do array `optionals_blocks` em uma nova linha, exibindo os parâmetros processados.

#### Resumo:
A função `read_optionals` verifica se a lista de parâmetros opcionais deve ser lida de um arquivo (caso o valor comece com `"default"`) ou tratada diretamente como uma string. Os parâmetros são divididos pelo delimitador `|` e exibidos no console, um por linha.

### 5. read_projectid

A função `read_projectid` recebe uma lista de IDs de projetos como entrada, divide essa lista em partes individuais e aplica uma sanitização a cada um dos IDs.

#### Explicação detalhada:

1. **`local projectid=$1`**:
   - Armazena o primeiro argumento passado para a função na variável `projectid`. Esse valor deve ser uma string contendo IDs de projetos, possivelmente separados por um delimitador.

2. **`local project_ids=()`**:
   - Inicializa um array vazio chamado `project_ids`, que será usado para armazenar os IDs de projeto processados.

3. **`IFS='|' read -ra project_ids <<< "$projectid"`**:
   - A string contida na variável `projectid` é dividida usando o delimitador `|`, e os resultados são armazenados no array `project_ids`. O `IFS='|'` define o separador de campos como `|`.

4. **`for item in "${project_ids[@]}"; do`**:
   - Inicia um loop para iterar sobre cada elemento do array `project_ids`.

5. **`sanitize_variable $item`**:
   - Para cada item (ID de projeto), a função `sanitize_variable` é chamada, passando o ID como argumento. Isso geralmente serve para limpar ou ajustar o valor do ID.

#### Resumo:
A função `read_projectid` processa uma lista de IDs de projeto fornecida como uma string, dividindo-a em partes usando o delimitador `|`. Cada ID é passado pela função `sanitize_variable` para garantir que não contenha caracteres indesejados ou espaços extras.

### 6. get_qandalf_version

A função `get_qandalf_version` verifica a presença do artefato `qandalf` no arquivo `pom.xml` e retorna a versão correspondente.

#### Explicação:

1. **Verificação do artefato**:
   - A função usa `grep` para procurar a linha `<artifactId>qandalf</artifactId>` em `pom.xml`.

2. **Retorno da versão**:
   - Se a linha for encontrada, a função retorna `3`.
   - Se não for encontrada, a função retorna `2`.

#### Resumo:
A função determina se o artefato `qandalf` está presente no arquivo `pom.xml` e retorna `3` ou `2`, dependendo do resultado.

### 7. find_scenario

A função `find_scenario` busca um arquivo Java correspondente a um cenário fornecido e retorna o nome do arquivo sem a extensão.

#### Explicação:

1. **Entrada**:
   - Recebe um nome de cenário como argumento (`$1`) e armazena na variável `CENARIO`.

2. **Busca do arquivo**:
   - Usa o comando `find` para procurar arquivos `.java` que correspondam ao nome do cenário no diretório especificado por `root_dir`. O comando `head -n 1` pega apenas o primeiro resultado encontrado.

3. **Verificação**:
   - Se nenhum arquivo for encontrado (`$arquivo` estiver vazio), a função imprime o nome do cenário e retorna `1`.

4. **Retorno do nome do arquivo**:
   - Se um arquivo for encontrado, a função imprime o nome do arquivo (sem a extensão) usando `basename`.

#### Resumo:
A função busca um arquivo Java correspondente a um cenário e retorna o nome do arquivo sem a extensão. Se nenhum arquivo for encontrado, retorna o nome do cenário e um código de erro.

### 8. get_framework_param

A função `get_framework_param` retorna parâmetros específicos com base no framework de teste fornecido (`Cucumber` ou `JUnit`).

#### Explicação:

1. **Entrada**:
   - Recebe o nome do framework como argumento (`$1`) e o armazena na variável `framework`.

2. **Estrutura de controle**:
   - Usa um `case` para verificar o valor da variável `framework`.

3. **Parâmetros para Cucumber**:
   - Se o framework for `"Cucumber"`:
     - Retorna um parâmetro baseado na versão do Qandalf:
       - Se `QANDALF_VERSION` for `3`, retorna `-Dcucumber.filter.tags=@${CENARIO}`.
       - Caso contrário, retorna `-Dcucumber.options="--tags'@${CENARIO}'"`.

4. **Parâmetros para JUnit**:
   - Se o framework for `"JUnit"`:
     - Retorna `-Dtest=${CENARIO}`.

#### Resumo:
A função determina e retorna os parâmetros apropriados para os frameworks de teste Cucumber ou JUnit, dependendo do cenário e da versão do Qandalf.

### 9. maven_command

A função `maven_command` executa um comando Maven para um cenário específico, gerencia logs e trata resultados de execução, além de coletar métricas se o teste for bem-sucedido.

#### Explicação:

1. **Entradas**:
   - Recebe quatro argumentos:
     - `CENARIO`: o nome do cenário de teste.
     - `ACTION`: a ação Maven a ser executada.
     - `OPTIONALS`: parâmetros opcionais para o comando Maven.
     - `PROJECT_ID`: o ID do projeto.

2. **Preparação do ambiente**:
   - Obtém parâmetros específicos para o framework chamando `get_framework_param`.
   - Cria uma cópia do diretório `/app` em `/tmp` com o nome do cenário.

3. **Definição do comando Maven**:
   - Monta a variável `RUN_CMD`, que contém o comando Maven a ser executado, incluindo opções como usuário e senha do ALM, e o parâmetro do framework.

4. **Log do comando**:
   - Registra o comando Maven em um arquivo de log.

5. **Execução do comando**:
   - Verifica se a imagem do Docker é `uftdeveloper`:
     - Se sim, configura argumentos específicos do Chrome e executa o script do LeanFT.
     - Caso contrário, executa o comando Maven diretamente.

6. **Tratamento de resultados**:
   - Após a execução, move os resultados da execução para um diretório específico.
   - Se o comando falhar (código de saída diferente de zero), registra um erro no log e adiciona o cenário à lista de testes falhados.
   - Se for bem-sucedido, renomeia o log para indicar sucesso e, se o framework for JUnit, coleta métricas.

7. **Retorno**:
   - Retorna o código de saída da execução.

#### Resumo:
A função `maven_command` executa um comando Maven para um cenário de teste, gerencia logs de execução e coleta métricas em caso de sucesso. Trata de forma apropriada tanto os cenários bem-sucedidos quanto os que falham.

### 10. handle_exit

A função handle_exit é chamada quando a execução do script é cancelada ou interrompida, realizando tarefas de limpeza e informando sobre cenários não executados.

#### Explicação detalhada:

1. **`"[$(date '+%Y-%m-%d %H:%M:%S')][WARNING] Pipeline cancelada. Finalizando execuções..."`**:
   - Esta linha imprime uma mensagem de aviso com a data e a hora atuais, indicando que a pipeline foi cancelada. O formato da data é YYYY-MM-DD HH:MM:SS, o que ajuda a rastrear quando a interrupção ocorreu.

2. **`restante=("${!PIDS[@]}" "${CENARIOS_RESTANTES[@]}")`**:
   - A variável restante é preenchida com todos os PIDs armazenados na matriz PIDS e os cenários restantes na matriz CENARIOS_RESTANTES.
   - ("${!PIDS[@]}") captura os índices dos PIDs em execução, enquanto ("${CENARIOS_RESTANTES[@]}") obtém os cenários que ainda não foram executados.

3. **`if [[ ${#restante[@]} -gt 0 ]]; then`**:
   - Verifica se existem elementos na matriz restante. A condição -gt 0 (maior que zero) determina se há processos ou cenários não executados.

4. **`echo "[WARNING] Cenário(s) $(echo "${restante[@]}" | tr ' ' ',') não executado(s)!"`**:
   - Se a condição for verdadeira, imprime um aviso listando os cenários não executados. A substituição de espaços por vírgulas (tr ' ' ',') melhora a legibilidade da lista.

#### Resumo:
   A função handle_exit gerencia a finalização de um script ao cancelar uma execução, informando ao usuário sobre quaisquer cenários que não foram executados e garantindo que o script seja encerrado de forma limpa e organizada.

### 11. unset_array

A função unset_array é usada para liberar variáveis de array no shell, removendo-as completamente da memória do script. Isso é útil especialmente para scripts intensivos em arrays, onde é necessário garantir que o array seja redefinido ou removido para liberar recursos.

#### Explicação detalhada:

1. **`unset "${1}[@]"`**:
   - Esta linha remove (unset) o array cujo nome é passado como argumento $1.
   - ${1}[@] refere-se ao conteúdo completo do array fornecido pelo nome da variável.
   - A execução de unset dessa forma apaga todos os elementos do array, liberando a memória e recursos associados a ele.

#### Resumo:

A função unset_array permite a remoção de arrays específicos passados como parâmetro, o que ajuda a gerenciar o uso de memória em scripts e evitar acúmulo de dados indesejados em arrays.

### Execução de Testes

- **`execution_echo`**: Exibe no terminal os detalhes da execução, como o framework e o cenário atual.
- **`get_framework_param`**: Retorna os parâmetros necessários para o Maven baseado no framework (Cucumber ou JUnit).
- **`maven_command`**: Executa o comando Maven de acordo com o framework e cenários configurados. Faz logging de falhas e sucessos para cada execução de teste.

### Coleta de Métricas

- **`collect_metrics`**: A função `collect_metrics` coleta métricas de teste usando o Maven, com base em um cenário específico e em um ID de projeto.

#### Explicação:

1. **Entradas**:
   - Recebe três argumentos:
     - `CENARIO`: o nome do cenário para o qual as métricas serão coletadas.
     - `PROJECT_ID`: o ID do projeto associado.
     - `LOG_FILE_NAME`: o nome do arquivo de log para registrar a saída da execução.

2. **Montagem do Comando Maven**:
   - Define a variável `CMD`, que contém o comando Maven para limpar e executar os testes. O comando inclui várias propriedades que são passadas como parâmetros:
     - `-Dtest=App`: especifica a classe de teste.
     - `-Dproject-Id=${PROJECT_ID}`: passa o ID do projeto.
     - `-Dscenario=${CENARIO}`: passa o nome do cenário.
     - `-Dtype=scenario`: define o tipo como cenário.
     - `-Dproject-version=${VERSION}`: inclui a versão do projeto.
     - `-Dproject-artifactId=${ARTIFACT_ID}`: inclui o ID do artefato do projeto.
     - Outras opções como `user.timezone`, `maven.repo.local`, e `style.color`.

3. **Registro no Log**:
   - Imprime uma linha separadora no log.
   - Registra informações sobre a coleta de métricas e o comando Maven a ser executado.

4. **Execução do Comando**:
   - Usa `eval` para executar o comando Maven, redirecionando a saída padrão e de erro para o arquivo de log correspondente.

#### Resumo:
A função `collect_metrics` executa um comando Maven para coletar métricas de teste, registrando informações relevantes em um arquivo de log e garantindo que as propriedades do projeto e do cenário sejam passadas corretamente.

## Logs e Resultados

- Todos os logs são armazenados no diretório `/logs/`.
- Resultados de execução de testes são salvos em `/app/RunResults/`.
- Para cada cenário, logs de sucesso ou falha são criados e os logs de execução Maven são agrupados nesses arquivos.

### Controle de Execução

#### Loop de Execução para Cenários de Teste

Esta parte do script executa uma série de cenários de teste em paralelo, gerenciando os parâmetros relevantes e verificando as condições necessárias para cada cenário.

#### Explicação:

1. **Inicialização**:
   - `i=0`: Inicializa um contador para iterar sobre os blocos de cenários.

2. **Loop Principal**:
   - `for BLOCK in "${SCENARIOS_BLOCKS[@]}"`: Itera sobre cada bloco de cenários armazenados na array `SCENARIOS_BLOCKS`.

3. **Obtenção de Parâmetros**:
   - `OPTIONALS=${OPTIONALS_BLOCKS[$i]}`: Obtém os parâmetros opcionais correspondentes ao índice atual.
   - `PROJECT_ID=${PROJECT_IDS[$i]}`: Obtém o ID do projeto correspondente ao índice atual.

4. **Divisão de Cenários**:
   - `IFS=',|' read -ra CENARIOS <<< "$BLOCK"`: Divide o bloco atual em uma array chamada `CENARIOS` usando `,` ou `|` como delimitadores.

5. **Loop Interno**:
   - `for CENARIO in "${CENARIOS[@]}"`: Itera sobre cada cenário na array `CENARIOS`.

6. **Verificação do Framework**:
   - Se o `FRAMEWORK` for `"Cucumber"`:
     - Chama a função `execution_echo` para indicar que está executando um teste Cucumber.
   - Se o `FRAMEWORK` for `"JUnit"`:
     - Usa a função `find_scenario` para localizar o arquivo correspondente ao cenário.
     - Se o cenário não for encontrado (`$? -ne 0`), exibe uma mensagem de erro e continua para o próximo cenário.
     - Chama `execution_echo` para indicar que está executando um teste JUnit e define `ACTION="clean"`.
   - Se o `FRAMEWORK` não for válido, exibe uma mensagem de erro e encerra a execução.

7. **Execução do Comando Maven**:
   - Chama a função `maven_command` passando os parâmetros relevantes e executa em segundo plano (`&`).
   - Armazena o PID do processo na array `PIDS` usando o nome do cenário como chave.

8. **Incremento do Índice**:
   - `((i++))`: Incrementa o contador `i` para passar para o próximo bloco de cenários.

#### Resumo:
Este código executa cenários de teste em paralelo, tratando cada um de acordo com o framework especificado. Ele gerencia os parâmetros e verifica a existência dos arquivos de cenário antes da execução, garantindo que os testes sejam executados corretamente.

## Pré-Requisitos

- **Docker**: Certifique-se de que o Docker esteja configurado e acessível.
- **Maven**: O script assume que Maven está disponível e configurado corretamente dentro do container Docker.
- **Licença LeanFT** (para `uftdeveloper`): Certifique-se de que a licença está disponível e os servidores de licença estão acessíveis.

## Como Usar

1. Ajuste as variáveis de ambiente conforme necessário.
2. Execute o script dentro de um ambiente configurado para Docker e Maven.
3. Monitore os logs gerados durante a execução dos cenários para obter feedback sobre sucessos ou falhas.