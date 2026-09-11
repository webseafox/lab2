import sys
import time

wlsAdmin = sys.argv[1]
wlsPassword = sys.argv[2]
wlsUrl = sys.argv[3]
appNome = sys.argv[4]
appArtefatoPath = sys.argv[5]
appTarget = sys.argv[6]
appVersion = sys.argv[7]

appNomeVersionado = appNome + '#' + appVersion

try:
    print 'Conectando no AdminServer.....'
    connect(wlsAdmin, wlsPassword, wlsUrl)
    print 'Conectado!'
except WLSTException, e:
    print 'Erro ao conectar no AdminServer!'
    print e
    dumpStack()
    exit(exitcode=1)

try:
    print 'Verificando se existe Edit Lock ativo...'
    edit()
    configManager = getConfigManager()
    if configManager.isEditor():
        editor = configManager.getCurrentEditor()
        print 'ERRO: Edit Lock ativo detectado!'
        print 'Usuario/sessao com lock: ' + str(editor)
        print 'Nao e possivel prosseguir com o deploy. Libere o Edit Lock manualmente.'
        cancelEdit('y')
        disconnect()
        exit(exitcode=1)
    else:
        print 'Nenhum Edit Lock ativo. Prosseguindo...'
        cancelEdit('y')
except WLSTException, e:
    print 'Erro ao verificar Edit Lock!'
    print e
    dumpStack()
    disconnect()
    exit(exitcode=1)

try:
    print '=============================================='
    print 'FASE: Deploy da nova versao'
    print '=============================================='
    print 'Aplicacao: ' + appNome
    print 'Versao: ' + appVersion
    print 'Nome versionado: ' + appNomeVersionado
    print 'Arquivo: ' + appArtefatoPath
    print 'Target: ' + appTarget

    import java.io.File as File
    warFile = File(appArtefatoPath)
    if not warFile.exists():
        print 'ERRO: Arquivo WAR nao encontrado: ' + appArtefatoPath
        disconnect()
        exit(exitcode=1)
    else:
        print 'Arquivo WAR encontrado. Tamanho: ' + str(warFile.length()) + ' bytes'

    print 'Iniciando deploy...'
    deploy(appName=appNomeVersionado, path=appArtefatoPath, targets=appTarget, stageMode='stage', upload='true', timeout=1200000)
    print 'Deploy realizado com sucesso!'
    disconnect()
    exit()
except WLSTException, e:
    print 'Erro ao realizar deploy da aplicacao ' + appNome + '!'
    print e
    dumpStack()
    disconnect()
    exit(exitcode=1)
