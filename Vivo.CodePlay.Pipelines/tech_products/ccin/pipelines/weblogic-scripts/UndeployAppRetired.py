import sys

wlsAdmin = sys.argv[1]
wlsPassword = sys.argv[2]
wlsUrl = sys.argv[3]
appNome = sys.argv[4]

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
    print 'Procurando pela aplicação ' + appNome + ' com status RETIRED...'
    cd('AppDeployments')
    apps=cmo.getAppDeployments()
    appEncontrada = 0
    for app in apps:
        if app.getApplicationName() == '' + appNome + '':
            cd('domainConfig:/AppDeployments/'+app.getName()+'/Targets')
            myTargets=ls(returnMap='true')
            cd('domainRuntime:/AppRuntimeStateRuntime/AppRuntimeStateRuntime')
            for targetinst in myTargets:
                curState=cmo.getCurrentState(app.getName(),targetinst)
                if curState=='STATE_RETIRED':
                    appEncontrada = 1
                    print 'Realizando undeploy da aplicação ' + appNome + ' com status RETIRED!'
                    undeploy(appName=app.getName())
                    print 'Undeploy realizado!'
    if appEncontrada == 0:
        print 'Não há aplicação ' + appNome + ' com status RETIRED neste Oracle WebLogic Server!'
    disconnect()
    exit()
except WLSTException, e:
    print 'Erro ao realizar undeploy da aplicação ' + appNome + '!'
    print e
    dumpStack()
    disconnect()
    exit(exitcode=1)