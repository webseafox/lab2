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

###  1.5 Análise do problema:
Foi avaliado que o componente footer no ambiente de Pre Produção/Stage possui divergências no alinhamento de icones e texto em relação ao figma.

###  1.6 Passo a passo para testes:


#### 1.6.1 Executar um build completo da aplicação usando o comando maven:

       mvn clean install -Padobe-public -PautoInstallBundle -PautoInstallPackage -Daem.port=4502

#### 1.6.2 Pacote(s) de conteúdo(s) a ser(em) instalado(s):

Não precisa instalar pacote de conteúdo para conseguir testar



#### 1.6.3 Após o build completo da aplicação, acessar o footer na versão desktop e mobile.

###  1.7 Evidências:

####  1.7.1 Layout do Figma (Desktop e mobile) e a versão do figma usada durante a implementação

#### * Layout do Figma versão Desktop

http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/f0c98b58bcc3cbfa03c8790354823393/image.png

#### * Layout do Figma versão Mobile
http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/a3477b61c6e3462069c9bfcfcfa84adb/image.png

####  1.7.2 Prints do componente footer com bugs (Opcional para atividades que não envolvem bugs):

#### * Print Desktop do componente footer com ícones desalinhados

http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/b625491581d07f94230512970613ed3a/image.png

#### * Print Mobile do componente footer com ícones desalinhados

http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/f99244af080e83fb9494f5356d175377/image.png

####  1.7.3 Prints do componente footer com as correções aplicadas:

#### * Print Desktop do componente footer com ícones alinhados
http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/6ff37eaf89998bd842055c8921e752bc/image.png

#### * Print Mobile do componente footer com ícones alinhados
http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/e3ae401baf5ffb1541f93266c8581161/image.png

####  1.7.4 Print do Dialog
Não teve necessidade de atuar no dialog.

####  1.7.5 Print do Build Completo
    mvn clean install -Padobe-public -PautoInstallBundle -PautoInstallPackage -Daem.port=4502
http://10.129.178.173:9080/ecommerce-b2b/aem/uploads/aecc0be7cfc848f1e8c64414677f0b46/image.png


##  2. Detalhes do Code Review

### 2.1 Responsável pelo code review
#### Fulano

### 2.2 Reproduzir os seguintes pontos:

2.2.1. [ x ] Fez um **git checkout** da branch citada no item **1.3.1**

2.2.2. [ ] Instalou pacote(s) de conteúdo(s) citado no passo **1.6.1**.

2.2.3. [ ] Executou os comandos "**npm run lint:prod**" e "**npm run stylelint**"

2.2.4 [ x ] Executou um **build completo da aplicação**, 
seguindo o comando apresentado no item **1.6.2**.

2.2.5 [ x ] Conseguiu reproduziu os passos apresentado no item **1.6**, conforme o figma.


### 2.3 Analisar o código

2.3.1. [ x ] Existe texto default no Dialog?

2.3.2. [ x ] A Nomenclatura dos componente esta usando o texto inglês e separado por "-"?

2.3.4. [ x ] Esta usando variáveis das cores?

2.3.5. [ x ] O desenvolvedor removeu códigos comentados (Caso, não tenha removido peça para atualizar o código)?

2.3.6. [ x ] Esta usando REM ou EM?

2.3.7. [ x ] Os ícones e imagens estão editáveis via dialog?

2.3.8. [ x ] Duplicou o componente na mesma página para ver se continua funcionando?