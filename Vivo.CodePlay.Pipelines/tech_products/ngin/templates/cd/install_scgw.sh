#!/bin/bash

current_version=""

verify_oms_hosts() {
    hosts_to_verify="oms sooms oms1 oms2"
    missing_hosts=""

    for host in $hosts_to_verify; do
        if ! grep -q "\<$host\>" /etc/hosts; then
            echo "Host $host not found in /etc/hosts"
            if [ -n "$missing_hosts" ]; then
                missing_hosts+=" "
            fi
            missing_hosts+="$host"
        fi
    done

    if [ -n "$missing_hosts" ]; then
        echo "Os seguintes hosts não foram encontrados: $missing_hosts"
        return 1
    else
        echo "Todos os hosts necessários foram encontrados em /etc/hosts"
    fi
}

config_oms_integration(){
    verify_oms_hosts
    if [ $? -ne 0 ]; then
        echo "Erro na verificação de hosts OMS."
        return 1
    else
        local service_name="scgw-oms"

        #Agora realizamos o download e instalação do artefato
        echo -e "----------------------------------------------"
        rpm_file="oms-package-${VERSION}-rpm.rpm"
        echo -e "\nRealizando download o artefato: $rpm_file\n"
        
        
        
        
        
        
file_uri="https://nexus.telefonica.com.br/repository/ngin-mvn/br/com/eisa/smarts/oms-tools/oms-package/${VERSION}/oms-package-${VERSION}-rpm.rpm"
check_uri="https://nexus.telefonica.com.br/repository/ngin-mvn/br/com/eisa/smarts/oms-tools/oms-package/${VERSION}/oms-package-${VERSION}-rpm.rpm.sha1"

file_download=$(wget -nv --http-user=${NEXUS_USER} --http-password=${NEXUS_PASSWORD} -O oms-package-${VERSION}-rpm.rpm $file_uri 2>&1)
exit_code=$?

if echo "$file_download" | grep -q "404"; then
                echo "Erro 404 - Arquivo não encontrado no Nexus: $file_uri"
                exit 1
elif [ $exit_code -ne 0 ]; then
                echo "Falha no download. Código de saída: $?"
                exit 1
else
                echo "Download concluído: ${file_uri}"
fi

check_file_download=$(wget -nv --http-user=${NEXUS_USER} --http-password=${NEXUS_PASSWORD} -O oms-package-${VERSION}-rpm.rpm.sha1 $check_uri  2>&1)
exit_code=$?

if echo "$check_file_download" | grep -q "404"; then
                echo "Erro 404 - Arquivo não encontrado no Nexus: $check_uri"
                exit 1
elif [ $exit_code -ne 0 ]; then
                echo "Falha no download. Código de saída: $exit_code"
                exit 1
else
                echo "Download concluído: ${check_uri}"
fi

downloaded_sum=$(cat oms-package-${VERSION}-rpm.rpm.sha1)
calculated_sum=$(sha1sum oms-package-${VERSION}-rpm.rpm | awk '{print $1}')

echo -e "\nChecksum usando SHA-1 para garantir que o arquivo baixado está íntegro:\n"

echo "SHA-1 obtido do Nexus: $downloaded_sum"
echo "SHA-1 calculado do arquivo RPM: $calculated_sum"



if [ "$downloaded_sum" == "$calculated_sum" ]; then
        echo -e "Verificação de SHA-1 bem sucedida.\n"
else
        echo "Erro: Verificação de SHA-1 falhou. Arquivo não parece ter sido baixado com sucesso. Impossível prosseguir."
        exit 1
fi

        
        
        
        
        

        
        
        
        
        
        echo -e "----------------------------------------------"
        echo -e "\nParando o serviço $service_name\n"
        sudo systemctl stop $service_name
        sleep 1
        
        status_output=$(systemctl is-active "$service_name")
        if [[ ! "$status_output" == "unknown" ]]; then
            echo -e "----------------------------------------------"
            echo -e "\nRemovendo versão instalada do serviço $service_name\n"
            echo "y" | sudo -S yum erase "$service_name"
            sleep 5
            
            status_output=$(systemctl is-active "$service_name")
            if [[ "$status_output" == "unknown" ]]; then
                echo "Remoção realizada com sucesso"
            else
                echo "Remoção não realizada com sucesso. Status do serviço é $status_output"
            fi
        fi
        
        echo -e "----------------------------------------------"
        echo -e "\nInstalando nova versão do $service_name\n"
        
        echo "y" | sudo -S yum localinstall "$rpm_file"
        sleep 5
        status_output=$(systemctl is-active "$service_name")
        if [[ "$status_output" == "unknown" ]]; then
            echo -e "\nServiço não encontrado. Um problema ocorreu na etapa de instalação do módulo.\n"
            exit 1
        else
            echo -e "\nMódulo instalado com sucesso\n"
    
        fi
        
        echo -e "----------------------------------------------"
        echo -e "\nVerificando status do $service_name...\n"
        sleep 10
        service_status=$(systemctl is-active "$service_name")
        if [ "$service_status" == "active" ]; then
            echo "Serviço $service_name está em estado Active"
        else
            echo "Serviço $service_name não está num estado ativo. Estado atual: $service_status."        
            if [ -v JAVA_8_PATH ]; then
                echo "JAVA_8_PATH está definido com o valor '$JAVA_8_PATH'. Não é possível realizar configuração do scgw-oms. Verifique o valor da variável."
                exit 1
            else
                script_path="/opt/eisa/smartcgw/oms/scripts/start-oms-agent.sh"
                echo "Variável de ambiente JAVA_8_PATH não está definida. Passo alternativo será realizado, com a inclusão no script $script_path"
                
                #TODO: retornar a linha abaixo para ambientes da vivo
                #java_path=$(update-alternatives --display java | grep -v slave | grep '1.8' | awk '{print $1}')
                java_path=$(find / -name 'java' -type f 2>/dev/null | grep "1.8" | head -n 1)
                #java_path="/opt/eisa/smartcgw/jdk1.8.0_202/bin/java"
                
                if [[ "$java_path" = "" ]]; then
                    echo "Não foi possível encontrar o JDK 1.8 na máquina."
                    exit 1
                fi

                line_to_add="export JAVA_8_PATH=\"$java_path\""

                # Verifica se a linha já está presente no script
                if grep -qF "export JAVA_8_PATH=" "$script_path"; then
                    echo "JAVA_8_PATH já está presente no script. Verifique manualmente o caminho fornecido. Não é possível realizar configuração OMS."
                    exit 1
                else
                    # Adiciona a linha ao script
                    sed -i "1a\\
                    $line_to_add" "$script_path"
                    echo "JAVA_8_PATH adicionada ao script de start com sucesso."
                fi

                echo "Realizando restart do serviço..."
                sudo systemctl restart scgw-oms
                sleep 10
                service_status=$(systemctl is-active "$service_name")
                if [ "$service_status" == "active" ]; then
                    echo "Sucesso na configuração do OMS. Serviço $service_name está em estado $service_status"
                else
                    echo "Configuração do OMS não foi bem sucedida: Serviço $service_name está em estado $service_status"
                    exit 1
                fi
            fi        
        fi
    fi
}

configs_backup(){
    local module=$1
    local version=$2
    
    if [[ "${MODULE}" == "scgw-app" ]]; then
        local service_name="${MODULE}"
    else
        local service_name="${MODULE}-app"
    fi
    

    echo -e "----------------------------------------------"
    echo -e "Executando backup das configurações da versão atual do $service_name"

    current_version_path=$(readlink -f /opt/eisa/smartcgw/$service_name/LATEST)
    if [[ "$current_version_path" == "" ]]; then
        echo "Módulo não encontrado. Pulando a etapa de backup"
    else
        current_version=$(basename "$current_version_path")
        backup_dir="/tmp/backup-files/$service_name/$current_version"
        mkdir -p backup_dir

        cp -r -a "/opt/eisa/smartcgw/$service_name/$current_version/config/" "$backup_dir"

        echo -e "Backup das configurações realizado com sucesso\n"
    fi
}

rollback() {
    if [[ "$current_version" == "" ]]; then
        echo "Não é possível realizar rollback pois não foi encontrada versão do módulo instalada anteriormente"
    else 
        download_and_install_scgw_module "${MODULE}" "$current_version" "1"
    fi
}

copy_backup_config_dir_to_current(){
    local module_name=$1
    echo -e "----------------------------------------------"
    echo -e "\nPrestes a copiar diretório de configuração do backup para dentro da aplicação atual\n"

    cp -r -a "$backup_dir/config/" "/opt/eisa/smartcgw/${MODULE}/$current_version/"

    echo -e "\nDiretório de configuração copiado com sucesso\n"
}

config_application_properties() {
    echo "Iniciando configuração do arquivo application.properties"

    local module_name=$1
    local version=$2

    echo "Configurando application.properties do ${MODULE} em versão ${VERSION}"

    if [ "${MODULE}" == "scgw-app" ]; then
        # Devido a questões específicas de convenção de nome do módulo scgw-app, foi necessário separá-lo dos módulos scgw-cdr e scgw-sync, apesar deles necessitarem de configuração idêntica
        sed -i "s/^spring.redis.cluster.nodes=.*/spring.redis.cluster.nodes=${REDIS_CLUSTER_NODES}/" "/opt/eisa/smartcgw/scgw-app/LATEST/config/application.properties"
    elif [ "${MODULE}" == "scgw-cdr" ] || [ "${MODULE}" == "scgw-tools" ]; then
        # Ambos os módulos possuem configuração idêntica. Caso surja uma diferença, basta evoluir esse conjunto de ifs/elifs para separar o módulo
        sed -i "s/^spring.redis.cluster.nodes=.*/spring.redis.cluster.nodes=${REDIS_CLUSTER_NODES}/" "/opt/eisa/smartcgw/${MODULE}-app/LATEST/config/application.properties"
    elif [ "${MODULE}" == "scgw-sync" ]; then
        sed -i "s/^spring.redis.cluster.nodes=.*/spring.redis.cluster.nodes=${REDIS_CLUSTER_NODES}/" "/opt/eisa/smartcgw/${MODULE}-app/LATEST/config/application.properties"
        # 0-32,33-64,65-97,98-119   -> para isso, já temos o que precisamos: CACHENRT_ENVS
        sed -i "s/^scgw.sync.slr.threadRanges=.*/scgw.sync.slr.threadRanges=TODO_calculo_threads_range/" "/opt/eisa/smartcgw/${MODULE}-app/LATEST/config/application.properties"
    elif [ "${MODULE}" == "scgw-rrp" ]; then
        sed -i "s/^spring.redis.cluster.nodes=.*/spring.redis.cluster.nodes=${REDIS_CLUSTER_NODES}/" "/opt/eisa/smartcgw/${MODULE}-app/LATEST/config/application.properties"
        sed -i "s/^currentSite=.*/currentSite=${ENVIRONMENT}/" "/opt/eisa/smartcgw/${MODULE}-app/LATEST/config/application.properties"
        #--------------------TODO: outras properties:
        #rrp.replicator.uris=redis://127.0.0.1:6379?authPassword=redis-dev-password-scgw&authUser=default&retries=0,redis://127.0.0.1:6380?authPassword=redis-dev-password-scgw&authUser=default&retries=0,redis://127.0.0.1:6381?authPassword=redis-dev-password-scgw&authUser=default&retries=0
        #known.redis.clusters[0].site=jaguare
        #known.redis.clusters[0].nodes=127.0.0.1:6379,127.0.0.1:6380,127.0.0.1:6381,127.0.0.1:6382,127.0.0.1:6383,127.0.0.1:6384
    else
        echo "Módulo inválido. Não será possível realizar configuração do application.properties."
    fi

    echo "Finalizada configuração do application.properties"
}

download_and_install_scgw_module() {
    local module_name=$1
    local version=$2
    local is_rollback_instalation_ongoing=$3

    local rpm_file="${MODULE}-rpm-${VERSION}-rpm.rpm"
    echo "rpm file name: $rpm_file"

    if [[ "${MODULE}" == "scgw-app" ]]; then
        local service_name="${MODULE}"
    else
        local service_name="${MODULE}-app"
    fi
    

    allowed_modules="scgw-app scgw-cdr scgw-sync scgw-tools scgw-rrp"
    if [[ ! " $allowed_modules " =~ " ${MODULE} " ]]; then
        echo "Erro: Módulo fornecido é inválido. Opções válidas são: $allowed_modules"
        exit 1
    fi

    echo -e "----------------------------------------------"
    echo "Executando download do artefato: $rpm_file"

#-------------------------------------


file_uri="https://nexus.telefonica.com.br/repository/ngin-mvn/br/com/eisa/smarts/scgw/package/${MODULE}-rpm/${VERSION}/${MODULE}-rpm-${VERSION}-rpm.rpm"
check_uri="https://nexus.telefonica.com.br/repository/ngin-mvn/br/com/eisa/smarts/scgw/package/${MODULE}-rpm/${VERSION}/${MODULE}-rpm-${VERSION}-rpm.rpm.sha1"

file_download=$(wget -nv --http-user=${NEXUS_USER} --http-password=${NEXUS_PASSWORD} -O ${MODULE}-rpm-${VERSION}-rpm.rpm $file_uri 2>&1)
exit_code=$?

if echo "$file_download" | grep -q "404"; then
                echo "Erro 404 - Arquivo não encontrado no Nexus: $file_uri"
                exit 1
elif [ $exit_code -ne 0 ]; then
                echo "Falha no download. Código de saída: $?"
                exit 1
else
                echo "Download concluído: ${file_uri}"
fi

check_file_download=$(wget -nv --http-user=${NEXUS_USER} --http-password=${NEXUS_PASSWORD} -O ${MODULE}-rpm-${VERSION}-rpm.rpm.sha1 $check_uri  2>&1)
exit_code=$?

if echo "$check_file_download" | grep -q "404"; then
                echo "Erro 404 - Arquivo não encontrado no Nexus: $check_uri"
                exit 1
elif [ $exit_code -ne 0 ]; then
                echo "Falha no download. Código de saída: $exit_code"
                exit 1
else
                echo "Download concluído: ${check_uri}"
fi

downloaded_sum=$(cat ${MODULE}-rpm-${VERSION}-rpm.rpm.sha1)
calculated_sum=$(sha1sum ${MODULE}-rpm-${VERSION}-rpm.rpm | awk '{print $1}')

echo -e "\nChecksum usando SHA-1 para garantir que o arquivo baixado está correto:\n"

echo "SHA-1 obtido do Nexus: $downloaded_sum"
echo "SHA-1 calculado do arquivo RPM: $calculated_sum"

if [ "$downloaded_sum" == "$calculated_sum" ]; then
        echo "Verificação de SHA-1 bem sucedida."
else
        echo "Erro: Verificação de SHA-1 falhou. Arquivo não parece ter sido baixado com sucesso. Impossível prosseguir."
        exit 1
fi



#------------------------------------

    echo -e "----------------------------------------------"
    echo -e "\nVerificando a pré-existência do serviço $service_name na máquina\n"
    
    status_output=$(systemctl is-active "$service_name")
    if [[ "$status_output" == "unknown" ]]; then
        echo "Serviço não instalado anteriormente. Pulando etapa de exclusão da versão anterior."
    else
        echo "Serviço encontrado"
        echo -e "----------------------------------------------"
        echo -e "\nExcluindo versão atual do ${MODULE}\n"

        echo "y" | sudo -S yum erase "$service_name"
        
        status_output=$(systemctl is-active "$service_name")
        if [[ "$status_output" == "unknown" ]]; then
            echo -e "\nExcluído com sucesso\n"
        else
            echo -e "\nNão foi possível remover serviço. Status do serviço é $status_output\n"
            exit 1
        fi
    fi

    echo -e "----------------------------------------------"
    echo -e "\nInstalando nova versão do ${MODULE}\n"
    
    echo "y" | sudo -S yum localinstall "$rpm_file"
    sleep 5
    status_output=$(systemctl is-active "$service_name")
    if [[ "$status_output" == "unknown" ]]; then
        echo -e "\nServiço não encontrado. Um problema ocorreu na etapa de instalação do módulo.\n"
        exit 1
    else
        echo -e "\nMódulo instalado com sucesso\n"
    fi

#    echo -e "----------------------------------------------"
#    echo -e "\nConfiguração do application properties\n"
#    
#    if [ ! -e "/opt/eisa/smartcgw/$service_name/LATEST/config/application.properties" ]; then
#        echo -e "Erro: o arquivo de application properties não existe no caminho: /opt/eisa/smartcgw/$service_name/LATEST/config/application.properties"
#        exit 1
#    fi
#    
#     if [ "$is_rollback_instalation_ongoing" = "1" ]; then
#        copy_backup_config_dir_to_current "${MODULE}"
#    else
#        config_application_properties "${MODULE}" "${VERSION}"
#    fi
#
#    echo -e "----------------------------------------------"
#    echo -e "\nReiniciando o módulo ${MODULE}...\n"
#
#    sudo systemctl restart "$service_name"
#    sleep 20
#
#    echo -e "----------------------------------------------"
#    echo -e "\nValidando status do módulo ${MODULE}\n"
#
#    status_output=$(systemctl is-active "$service_name")
#    if [[ "$status_output" == "active" ]]; then
#        echo "Instalação realizada com sucesso. Aplicação está em estado ativo."
#    else
#        echo "Ocorreu um problema após a instalação. O status da aplicação é $status_output."
#        
#        #if [ "$is_rollback_instalation_ongoing" = "1" ]; then
#        #    echo "Ocorreu um problema após rollback do ${MODULE}. A aplicação não está com status Active. Status é $status_output"
#        #else
#        
#        #    echo "Prestes a iniciar operação de rollback do módulo ${MODULE}"
#        #    rollback
#        #fi
#    fi
}

backup_and_install_module() {
    local module=$1
    local version=$2

    #scgw-oms
    if [[ "${MODULE}" == "scgw-oms" ]]; then
        config_oms_integration
        if [ $? -ne 0 ]; then
            echo "Erro na instalação do scgw-oms"
        fi
    else
        #scgw modules
        #configs_backup "${MODULE}" "${VERSION}"
        if [ $? -ne 0 ]; then
            echo "Erro ao realizar backup de configurações. Instalação não será executada."
            exit 1
        fi
        download_and_install_scgw_module "${MODULE}" "${VERSION}" "0"
    fi
}



#------------- Começo da execução ------------- 

echo -e "\n\n\n"
echo -e "=================================================="
echo -e "==Iniciando instalação do Smart Charging Gateway=="
echo -e "=================================================="
echo -e "\n\n\n"

echo -e "----------------------------------------------"

if [ "${IP}" == "" ]; then
    echo "\nIP_AMBIENTE não fornecido. Abortando.\n\n"
else 
    echo -e "\nPrestes a realizar a instalação do módulo ${MODULE}...\n\n"

    backup_and_install_module "${MODULE}" "${VERSION}"

    echo -e "\nFinalizada instalação do módulo ${MODULE}\n\n"
fi
echo "----------------------------------------------"

