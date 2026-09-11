import sys

wlsAdmin = sys.argv[1]
wlsPassword = sys.argv[2]
wlsUrl = sys.argv[3]
appNome = sys.argv[4]
appArtefatoPath = sys.argv[5]
appTarget = sys.argv[6]
appVersion = sys.argv[7]

try:
    print 'Conectando no AdminServer.....'
    connect(wlsAdmin,wlsPassword,wlsUrl)
    print 'Conectado!'
except WLSTException,e:
    print 'Erro ao conectar no AdminServer!'
    print e
    dumpStack()
    exit(exitcode=1)

try:
    # Nome da aplicação versionado para permitir múltiplas versões
    appNomeVersionado = appNome + '#' + appVersion
    print 'Fazendo deploy da aplicação ' + appNome + ' versão ' + appVersion + '!'
    print 'Arquivo: ' + appArtefatoPath
    print 'Nome versionado: ' + appNomeVersionado
    print 'Target: ' + appTarget
    
    # Verificar se o arquivo existe
    import java.io.File as File
    warFile = File(appArtefatoPath)
    if not warFile.exists():
        print 'ERRO: Arquivo WAR não encontrado: ' + appArtefatoPath
        exit(exitcode=1)
    else:
        print 'Arquivo WAR encontrado. Tamanho: ' + str(warFile.length()) + ' bytes'
    
    # Deploy com stage mode e timeout maior para resolver problemas de upload
    deploy(appName=appNomeVersionado,path=appArtefatoPath,targets=appTarget,stageMode='stage',upload='true',timeout=1200000)
    print 'Deploy realizado!'
    
    # Desconectar do AdminServer
    disconnect()
    
except WLSTException,e:
    print 'Erro ao realizar deploy da aplicação ' + appNome + '!'
    print e
    dumpStack()
    disconnect()
    exit(exitcode=1)