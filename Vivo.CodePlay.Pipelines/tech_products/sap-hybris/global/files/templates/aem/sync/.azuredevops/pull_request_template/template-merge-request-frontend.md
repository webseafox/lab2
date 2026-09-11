# TEMPLATE PADRÃO PARA MERGE RESQUEST

##  1. Detalhes da Atividade

###  1.1 Link do Jira:
[PTI1049-850]( https://jira.telefonica.com.br/browse/PTI1049-850)

###  1.2 Título da Atividade:

 Ajustar o footer

###  1.3 Detalhes da Branch

####  1.3.1 Título da Branch

[fix/PTI1049-850](http://10.129.178.173/ecommerce-b2b/aem/tree/fix/PTI1049-850)

####  1.3.2 Qual foi a branch que foi usada como base?

[release/ecommerce-equipments-project](http://10.129.178.173/ecommerce-b2b/aem/tree/release/ecommerce-equipments-project)

###  1.4 Breve descrição:
Alinhamento de ícones das redes sociais e texto no componente footer.



###  1.5 Passo a passo para testes:


#### 1.5.1 Executar um build completo da aplicação usando o comando maven:

       mvn clean install -Padobe-public -PautoInstallBundle -PautoInstallPackage -Daem.port=4502

#### 1.5.2 Pacote(s) de conteúdo(s) a ser(em) instalado(s):

Não precisa instalar pacote de conteúdo para conseguir testar



#### 1.5.3 Após o build completo da aplicação, acessar o footer na versão desktop e mobile.

###  1.6 Evidências:

####  1.6.1 Layout do Figma (Desktop e mobile) e a versão do figma usada durante a implementação

#### * Layout do Figma versão Desktop


#### * Layout do Figma versão Mobile


####  1.7.3 Prints do novo componente: 

#### * Print Desktop do componente

#### * Print Mobile do componente

####  1.7.4 Print do Dialog
Não teve necessidade de atuar no dialog.

####  1.7.5 Print do Build Completo
    mvn clean install -Padobe-public -PautoInstallBundle -PautoInstallPackage -Daem.port=4502

####  1.7.6 Print dos Testes do Cypress


##  2. Detalhes do Code Review

### 2.1 Responsável pelo code review
#### Fulano

### 2.2 Reproduzir os seguintes passos para conseguir analisar o código:

2.2.1. [  ] Fez um **git checkout** da branch citada no item **1.3.1**

2.2.2. [ ] Instalou pacote(s) de conteúdo(s) citado no passo **1.6.1**.

2.2.3. [ ] Executou os comandos "**npm run lint:prod**" e "**npm run stylelint**"


2.2.4 [  ] Atualizou o código conforme a branch de **develop - (release/ecommerce-equipments-project)**?


2.2.5 [  ] Executou um **build completo da aplicação**, 
seguindo o comando apresentado no item **1.6.2**. Por favor, coloque o print nos comentários do gitlab.

2.2.6 [  ] Conseguiu reproduziu os passos apresentado no item **1.6**, conforme o figma?



### 2.3 Analisar o código

2.3.1. [  ] Existe texto default no Dialog?

2.3.2. [  ] A Nomenclatura do componente esta usando o texto inglês e separado por "-"?

2.3.4. [  ] Esta usando variáveis das cores?

2.3.5. [  ] O desenvolvedor removeu códigos comentados (Caso, não tenha removido peça para atualizar o código)?

2.3.6. [  ] Esta usando REM ou EM?

2.3.7. [  ] Esta usando optional chaining (?.) no código Vue JS?

2.3.8. [  ] Os ícones e imagens estão editáveis via dialog?

2.3.9. [  ] Duplicou o componente na mesma página para ver se continua funcionando?

2.3.10. [  ] Testou o componente no modo de edição (author) e no modo de publicação (publish) usando parametro **wcmmode=disabled**?

Ex: 
   http://localhost:4502/editor.html/content/b2b/e-commerce-equipamentos/vitrine.html - modo de edição - author
   http://localhost:4502/content/b2b/e-commerce-equipamentos/vitrine.html?wcmmode=disabled - modo de publicação - publicação

2.3.11. [  ] Os Testes do Cypress foram atualizados conforme as atualizações no código dos componentes existentes?