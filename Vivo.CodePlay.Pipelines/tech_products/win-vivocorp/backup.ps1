Add-Type -Path "C:\Windows\Microsoft.NET\assembly\GAC_64\Oracle.DataAccess\odp.net\bin\4\Oracle.DataAccess.dll"

# Acessando as variáveis de ambiente
$AllSessionIds = $env:ALL_SESSION_IDS
$OracleHostPort = [int]$env:ORACLE_HOST_PORT
$OracleHostServiceName = $env:ORACLE_HOST_SERVICE_NAME
$OracleHostUser = $env:ORACLE_HOST_USER
$OracleHostPass = $env:ORACLE_HOST_PASS
$FirstOracleServer = $env:FIRST_ORACLE_SERVER
$SecondOracleServer = $env:SECOND_ORACLE_SERVER
$ThirdOracleServer = $env:THIRD_ORACLE_SERVER
$TargetOracleServer = $env:TARGET_ORACLE_SERVER
$TargetHostUser = $env:TARGET_ORACLE_HOST_USER
$TargetHostPass = $env:TARGET_ORACLE_HOST_PASS
$TargetHostServiceName = $env:TARGET_ORACLE_HOST_SERVICE_NAME
$LogPath = $env:LOG_PATH

function Write-Log {
    param (
        [string]$message,
        [string]$color = "White"
    )
    
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    
    $logFilePath = Join-Path -Path $LogPath -ChildPath "logfile.log"
    Add-Content -Path $logFilePath -Value $logMessage
    
    Write-Host $logMessage -ForegroundColor $color
}


function Write-Header {
    Write-Log "======================================================================================" "Yellow"
    Write-Log "=============================== INFORMATIONS =========================================" "Yellow"
    Write-Log "======================================================================================" "Yellow"

    Write-Log "=============================== GENERAL INFORMATION ABOUT HOSTS ======================" "Yellow"
    Write-Log "PORT (OracleHostPort): $OracleHostPort"
    Write-Log "SERVICE NAME: (OracleHostServiceName): $OracleHostServiceName"
    Write-Log "=============================== OBJECT SEARCH SERVERS ================================" "Yellow"
    Write-Log "FRIST OPTION (FirstOracleServer): $FirstOracleServer"
    Write-Log "SECOND OPTION (SecondOracleServer): $SecondOracleServer"
    Write-Log "THIRD OPTION (ThirdOracleServer): $ThirdOracleServer"
    Write-Log "======================================================================================" "Yellow"
    
    Write-Log "=============================== OBJECT PUBLISHING SERVERS ============================" "Yellow"
    Write-Log "TARGET ORACLE SERVER (TargetOracleServer): $TargetOracleServer"
    Write-Log "=============================== LOG PATH =============================================" "Yellow"
    Write-Log " LOG PATH (LogPath): $LogPath"
    Write-Log "======================================================================================" "Yellow"
    Write-Log "`n"
}

$userId = '1-PH21' # sbleim

function Insert-EMTSessnItm {
    param (
        [string]$ActiveFlag,
        [string]$DeployModeCD,
        [string]$EmtDsetItemId,
        [string]$EmtSessionId,
        [string]$SearchSpec
    )

    $escapedSearchSpec = $SearchSpec -replace "'", "''"

    Write-Log "======================================================================================"
    Write-Log "============= INFORMATIONS DB HOST (INSERT SIEBEL.S_EMT_SESSN_ITM) ==================="
    Write-Log "======================================================================================"
    Write-Log " HOST: $TargetOracleServer"
    Write-Log " PORT: $OracleHostPort"
    Write-Log " SERVICE NAME: $TargetHostServiceName"
    Write-Log "======================================================================================"

    $commandText = "INSERT INTO SIEBEL.S_EMT_SESSN_ITM (ROW_ID, CREATED, CREATED_BY, LAST_UPD, LAST_UPD_BY, MODIFICATION_NUM, CONFLICT_ID, ACTIVE_FLG, DEPLOY_MODE_CD, EMT_DSET_ITEM_ID, EMT_SESSION_ID, STATUS_CD, SYNC_FLG, DB_LAST_UPD, NUM_REC_TRANSFER, COMMENTS, DB_LAST_UPD_SRC, PAR_SESSN_ITM_ID, PDQ_ID, SEARCH_SPEC) VALUES ('1-' || LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(100000000000000, 999999999999999))), 13, '0'), SYSDATE, '$userId', SYSDATE, '$userId', 0, 0, '$ActiveFlag', '$DeployModeCD', '$EmtDsetItemId', '$EmtSessionId', 'Filter Validated', 'Y', SYSDATE, NULL, NULL, 'User', NULL, NULL, '$escapedSearchSpec')"
    Write-Log "$commandText"

    $connectionString = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$TargetOracleServer)(PORT=$OracleHostPort)))(CONNECT_DATA=(SERVICE_NAME=$TargetHostServiceName))); User Id=$TargetHostUser; Password=$TargetHostPass;"
    $oracleConnection = New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $oracleConnection.Open()
    $command = $oracleConnection.CreateCommand()
    $command.CommandText = $commandText
    $command.ExecuteNonQuery() | Out-Null
    $oracleConnection.Close()

    Write-Log "======================================================================================"
    Write-Log "====== REGISTRO DE SESSÃO DE FILHO FEITO COM SUCESSP (SIEBEL.S_EMT_SESSN_ITM) ========"
    Write-Log "======================================================================================"
    Write-Log "EMT_DSET_ITEM_ID: ${EmtDsetItemId}"
    Write-Log "EMT_SESSION_ID: ${EmtSessionId}"
    Write-Host "`n"
}

function Insert-EMTSession {
    param (
        [string]$EmtDataSetId,
        [string]$ExportFileFlg
    )

    Write-Log "======================================================================================"
    Write-Log "=========================== INSERT SIEBEL.S_EMT_SESSION) ============================="
    Write-Log "======================================================================================"
    $commandText = "INSERT INTO SIEBEL.S_EMT_SESSION (ROW_ID, CREATED, CREATED_BY, LAST_UPD, LAST_UPD_BY, MODIFICATION_NUM, CONFLICT_ID, EXPORT_FILE_FLG, FILE_AUTO_UPD_FLG, FILE_DEFER_FLG, FILE_DOCK_REQ_FLG, FILE_DOCK_STAT_FLG, LOCKED_FLG, SESSION_NUM, STATUS_CD, DB_LAST_UPD, FILE_DATE, FILE_SIZE, DB_LAST_UPD_SRC, DESC_TEXT, EMT_DATA_SET_ID, FILE_EXT, FILE_NAME, FILE_REV_NUM, FILE_SRC_PATH, FILE_SRC_TYPE, LOCKED_BY, TRGT_SERVER_PATH, TRGT_USER_LOGIN) VALUES ('1-' || LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(100000000000000, 999999999999999))), 13, '0'), SYSDATE,'$userId',SYSDATE,'$userId',0,0,'$ExportFileFlg','Y','R','N','N','Y','1-' || LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(100000000000000, 999999999999999))), 13, '0'),'New',SYSDATE,'','','User','Azure Pipeline Vivo Corp','$EmtDataSetId','','','','','FILE','$userId',NULL, NULL) RETURNING ROW_ID INTO :newRowId" 
    Write-Log "$commandText"

    $connectionString = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$TargetOracleServer)(PORT=$OracleHostPort)))(CONNECT_DATA=(SERVICE_NAME=$TargetHostServiceName))); User Id=$TargetHostUser; Password=$TargetHostPass;"
    $oracleConnection = New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $oracleConnection.Open()
    $command = $oracleConnection.CreateCommand()
    $command.CommandText = $commandText

    $newRowIdParam = New-Object Oracle.DataAccess.Client.OracleParameter(":newRowId", [Oracle.DataAccess.Client.OracleDbType]::Varchar2, 50)
    $newRowIdParam.Direction = [System.Data.ParameterDirection]::Output
    $command.Parameters.Add($newRowIdParam) | Out-Null

    $command.ExecuteNonQuery() | Out-Null

    $newRowId = $newRowIdParam.Value
    Write-Log "Registro de sessão de item feito com suceso (SIEBEL.S_EMT_SESSION): ROW_ID: $newRowId, EMT_DATA_SET_ID: $EmtDataSetId"

    $oracleConnection.Close()

    return $newRowId
}

function Get-RowIdFromProject {
    param (
        [string]$ProjectName,
        [string]$TableName
    )

    Write-Host "`n======================================================================================"
    Write-Host "============= INFORMATIONS DB HOST (SELECT SIEBEL.$TableName)"
    Write-Host "======================================================================================"
    Write-Host " HOST: $TargetOracleServer"
    Write-Host " PORT: $OracleHostPort"
    Write-Host " SERVICE NAME: $TargetHostServiceName"
    Write-Host "======================================================================================`n"

    $commandText = "SELECT ROW_ID FROM SIEBEL.$TableName WHERE NAME = :projectName"
    Write-Log "$commandText"

    $connectionString = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$TargetOracleServer)(PORT=$OracleHostPort)))(CONNECT_DATA=(SERVICE_NAME=$TargetHostServiceName))); User Id=$TargetHostUser; Password=$TargetHostPass;"
    $oracleConnection = New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $oracleConnection.Open()
    $command = $oracleConnection.CreateCommand()
    $command.CommandText = $commandText

    $parameter = New-Object Oracle.DataAccess.Client.OracleParameter(":projectName", [Oracle.DataAccess.Client.OracleDbType]::Varchar2, 50)
    
    $parameter.Value = $ProjectName
    $command.Parameters.Add($parameter) | Out-Null
    $reader = $command.ExecuteReader()
    
    $rowId = $null
    if ($reader.Read()) {
        $rowId = $reader["ROW_ID"]
        Write-Log "RESULTADO DA QUERY:"
        Write-Log "SERVIDOR: $TargetOracleServer"
        Write-Log "ROW_ID: $($reader['ROW_ID'])"        
    }
    $oracleConnection.Close()

    return $rowId
}

function Get-DataSetName {
    param (
        [string]$EmtDataSetId,
        [string]$TableName
    )
    $commandText = "SELECT NAME FROM SIEBEL.$TableName WHERE ROW_ID = :emtDataSetId"
    Write-Log "$commandText"

    $command = $oracleConnection.CreateCommand()
    $command.CommandText = $commandText
    $parameter = New-Object Oracle.DataAccess.Client.OracleParameter(":emtDataSetId", [Oracle.DataAccess.Client.OracleDbType]::Varchar2, 50)
    
    $parameter.Value = $EmtDataSetId
    $command.Parameters.Add($parameter) | Out-Null
    $reader = $command.ExecuteReader()
    
    if ($reader.Read()) {
        Write-Log "NAME: $($reader['NAME'])"        
        $name = $reader["NAME"]
        if ($name -eq "RuleSet") {
            return $null
        }
        return $name
    } else {
        return $null
    }
}

function Get-Adm {
    param (
        [string]$OracleHost,
        [int]$Port,
        [string]$ServiceName,
        [string]$SessionId,
        [ref]$objectFound
    )    
    $connectionString = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$OracleHost)(PORT=$Port)))(CONNECT_DATA=(SERVICE_NAME=$ServiceName))); User Id=$OracleHostUser; Password=$OracleHostPass;"
    
    Write-Log "======================================================================================"
    Write-Log "================================ BUSCANDO SESSION ID ================================="
    Write-Log "======================================================================================"
    Write-Log " HOST: ${OracleHost}"
    Write-Log " SESSION ID: ${SessionId}"
    Write-Log "======================================================================================"
    Write-Log "============================== QUERY (ADM) ==========================================="
    Write-Log "======================================================================================"
    $commandText = "SELECT COUNT(1) AS COUNT, ROW_ID, EMT_DATA_SET_ID, EXPORT_FILE_FLG FROM SIEBEL.S_EMT_SESSION WHERE S_EMT_SESSION.ROW_ID = :sessionId GROUP BY ROW_ID, EMT_DATA_SET_ID, EXPORT_FILE_FLG"
    Write-Log "$commandText"

    $oracleConnection = New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $oracleConnection.Open()
    $command = $oracleConnection.CreateCommand()
    $command.CommandText = $commandText

    $parameter = New-Object Oracle.DataAccess.Client.OracleParameter(":sessionId", [Oracle.DataAccess.Client.OracleDbType]::Varchar2, 50)
    $parameter.Value = $SessionId
    $command.Parameters.Add($parameter) | Out-Null
    $reader = $command.ExecuteReader()
    
    if ($reader.Read()) {
        Write-Log "SERVIDOR: $OracleHost"
        Write-Log "ROW_ID: $($reader['ROW_ID'])"
        Write-Log "EMT_DATA_SET_ID: $($reader['EMT_DATA_SET_ID'])"
        Write-Log "EXPORT_FILE_FLG: $($reader['EXPORT_FILE_FLG'])"
        Write-Host "`n"
        $objectFound.Value = $true
        
        Write-Log "======================================================================================"
        Write-Log "======================== QUERY (DATASET/S_EMT_DATA_SET) =============================="
        Write-Log "======================================================================================"
        $dataSetName = Get-DataSetName -EmtDataSetId "$($reader['EMT_DATA_SET_ID'])" -TableName "S_EMT_DATA_SET"
        if ($dataSetName) {
            Write-Log "HOST: ${OracleHost} (S_EMT_DATA_SET)"
            Write-Log "EMT_DATA_SET_ID: ${dataSetName}"
            Write-Log "======================================================================================"
            Write-Host "`n"
            $rowId = Get-RowIdFromProject -ProjectName $dataSetName -TableName "S_EMT_DATA_SET"
            
            $insertedRowId = $null
            if($rowId){
                Write-Log "======================================================================================"
                Write-Log "=============== RESULTADO DA QUERY (PROJETO/S_EMT_DATA_SET) =========================="
                Write-Log "======================================================================================"
                Write-Log "SERVIDOR: ${TargetOracleServer}"
                Write-Log "ROW_ID: ${rowId}"
                Write-Log "NAME: ${dataSetName}"

                $insertedRowId = Insert-EMTSession -EmtDataSetId $rowId -ExportFileFlg $($reader['EXPORT_FILE_FLG'])
            } else {
                Write-Log "**************************************************************************************" "Red"
                Write-Log "*********** ${dataSetName} NÃO ENCONTRADO EM ${TargetOracleServer} *******************" "Red"
                Write-Log "**************************************************************************************" "Red"
                Write-Host "`n"
            }

            $commandText = "SELECT EMT_DSET_ITEM_ID,ACTIVE_FLG,DEPLOY_MODE_CD,SEARCH_SPEC,PAR_SESSN_ITM_ID FROM SIEBEL.S_EMT_SESSN_ITM WHERE EMT_SESSION_ID = :sessionId"
            Write-Log "$commandText"
 
            $commandItem = $oracleConnection.CreateCommand()
            $commandItem.CommandText = $commandText
            $parameter = New-Object Oracle.DataAccess.Client.OracleParameter(":sessionId", [Oracle.DataAccess.Client.OracleDbType]::Varchar2, 50)
            $parameter.Value = $SessionId
            $commandItem.Parameters.Add($parameter) | Out-Null            
            $readerItem = $commandItem.ExecuteReader()

            
            if ($readerItem.Read()) {
                Write-Log "======================================================================================"
                Write-Log "======================== RESULTADO DA QUERY (ITEM) ===================================="
                Write-Log "======================================================================================"
                Write-Log "SERVIDOR: $OracleHost"
                Write-Log "EMT_DSET_ITEM_ID: $($readerItem['EMT_DSET_ITEM_ID'])"
                Write-Log "ACTIVE_FLG: $($readerItem['ACTIVE_FLG'])"
                Write-Log "DEPLOY_MODE_CD: $($readerItem['DEPLOY_MODE_CD'])"
                Write-Log "SEARCH_SPEC: $($readerItem['SEARCH_SPEC'])"
                Write-Log "PAR_SESSN_ITM_ID: $($readerItem['PAR_SESSN_ITM_ID'])"   
                Write-Log "======================================================================================"
                Write-Log "======================== QUERY (DATASET/S_EMT_DSET_ITEM) ============================="
                Write-Log "======================================================================================"
                $dataSetNameItem = Get-DataSetName -EmtDataSetId $($readerItem['EMT_DSET_ITEM_ID']) -TableName "S_EMT_DSET_ITEM"
                if ($dataSetNameItem) {
                    Write-Log "HOST: ${OracleHost} EM PRD (S_EMT_DSET_ITEM)"
                    Write-Log "EMT_DSET_ITEM_ID: ${dataSetNameItem}"
                    Write-Log "======================================================================================"

                    $rowItemId = Get-RowIdFromProject -ProjectName $dataSetNameItem -TableName "S_EMT_DSET_ITEM"

                    if($rowItemId){
                        Write-Log "======================================================================================"
                        Write-Log "=============== RESULTADO DA QUERY (PROJETO/S_EMT_DSET_ITEM) ========================="
                        Write-Log "======================================================================================"
                        Write-Log "SERVIDOR: ${TargetOracleServer}"
                        Write-Log "ROW_ID: ${rowItemId}"
                        Write-Log "NAME: ${dataSetNameItem}"
                        Write-Host "`n"

                        Insert-EMTSessnItm -ActiveFlag $readerItem['ACTIVE_FLG'] -DeployModeCD $readerItem['DEPLOY_MODE_CD'] -EmtDsetItemId $rowItemId -EmtSessionId $insertedRowId -SearchSpec $readerItem['SEARCH_SPEC']
                    } else {
                        Write-Log "**************************************************************************************" "Red"
                        Write-Log "*********** ${dataSetNameItem} NÃO ENCONTRADO EM ${TargetOracleServer} ***************" "Red"
                        Write-Log "**************************************************************************************" "Red"
                        Write-Host "`n"
                    }
                } else {
                    Write-Log "Não foi encontrado DATASET para o FILHO com ID: $($reader['EMT_DATA_SET_ID']) em ${TargetOracleServer}" "Red"
                }
            } else {
                Write-Log "Não foram encontrados FILHOS para o ITEM com SessionId: $SessionId" "Red"
            }
        } else {
            Write-Log "Não foi encontrado DATASET o ITEM com ID: $($reader['EMT_DATA_SET_ID']) em ${TargetOracleServer}" "Red"
        }
    }
    $oracleConnection.Close()
}

Write-Header

$sessionIdsArray = "$AllSessionIds".Split(',')

foreach ($sessionId in $sessionIdsArray) {   
    $objectFound = $false
    Write-Log "======================================================================================"
    Write-Log "===================== PRIMEIRA BUSCA ${FirstOracleServer}" "Green"
    Get-Adm -OracleHost $FirstOracleServer -Port $OracleHostPort -ServiceName $OracleHostServiceName -SessionId $sessionId -ObjectFound ([ref]$objectFound)
    if(!$objectFound){
        Write-Log "======================================================================================"
        Write-Log "===================== SEGUNDA BUSCA ${SecondOracleServer}" "Green"
        Get-Adm -OracleHost $SecondOracleServer -Port $OracleHostPort -ServiceName $OracleHostServiceName -SessionId $sessionId -ObjectFound ([ref]$objectFound)
        if(!$objectFound){
        Write-Log "======================================================================================"
        Write-Log "===================== TERCEIRA BUSCA ${ThirdOracleServer}" "Green"
        Get-Adm -OracleHost $ThirdOracleServer -Port $OracleHostPort -ServiceName $OracleHostServiceName -SessionId $sessionId -ObjectFound ([ref]$objectFound)
        if(!$objectFound){
                Write-Host "`n"
                Write-Log "**************************************************************************************" "Red"
                Write-Log "********************** ${sessionId} NÃO ENCONTRADO ***********************************" "Red"
                Write-Log "**************************************************************************************" "Red"
                Write-Host "`n"
            }
        } 
    }                   

}