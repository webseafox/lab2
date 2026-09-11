import sys
from time import sleep

wlsAdmin = sys.argv[1]
wlsPassword = sys.argv[2]
wlsUrl = sys.argv[3]
appNome = sys.argv[4]
delaySegundos = 10  # Delay de seguranca apos undeploy

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
    print 'Verificando se existe Edit Lock ativo...'
    edit()
    configManager = getConfigManager()
    if configManager.isEditor():
        editor = configManager.getCurrentEditor()
        print 'ERRO: Edit Lock ativo detectado!'
        print 'Usuario/sessao com lock: ' + str(editor)
        print 'Nao e possivel prosseguir com o undeploy. Libere o Edit Lock manualmente.'
        cancelEdit('y')
        disconnect()
        exit(exitcode=1)
    else:
        print 'Nenhum Edit Lock ativo. Prosseguindo...'
        cancelEdit('y')
except WLSTException,e:
    print 'Erro ao verificar Edit Lock!'
    print e
    dumpStack()
    disconnect()
    exit(exitcode=1)

try:
    print 'Procurando pela aplicacao ' + appNome + '...'
    cd('AppDeployments')
    apps = cmo.getAppDeployments()
    appEncontrada = 0
    for app in apps:
        if app.getApplicationName() == '' + appNome + '':
            appEncontrada = 1
            print 'Aplicacao encontrada: ' + app.getName()
            cd('domainConfig:/AppDeployments/' + app.getName() + '/Targets')
            myTargets = ls(returnMap='true')
            cd('domainRuntime:/AppRuntimeStateRuntime/AppRuntimeStateRuntime')
            for targetinst in myTargets:
                curState = cmo.getCurrentState(app.getName(), targetinst)
                print 'Estado atual da aplicacao no target ' + targetinst + ': ' + curState
            print 'Realizando undeploy da aplicacao ' + appNome + '...'
            undeploy(appName=app.getName(), timeout=120000)
            print 'Undeploy realizado com sucesso!'
    if appEncontrada == 0:
        print 'Nao ha aplicacao ' + appNome + ' deployada neste Oracle WebLogic Server. Prosseguindo...'
    else:
        print 'Aguardando ' + str(delaySegundos) + ' segundos para seguranca...'
        sleep(delaySegundos)
        print 'Delay concluido!'
    disconnect()
    exit()
except WLSTException, e:
    print 'Erro ao realizar undeploy da aplicacao ' + appNome + '!'
    print e
    dumpStack()
    disconnect()
    exit(exitcode=1)
