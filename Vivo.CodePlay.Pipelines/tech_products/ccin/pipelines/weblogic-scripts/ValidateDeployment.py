import sys

wlsAdmin = sys.argv[1]
wlsPassword = sys.argv[2]
wlsUrl = sys.argv[3]
appNome = sys.argv[4]

try:
    print 'Conectando no AdminServer para validacao.....'
    connect(wlsAdmin,wlsPassword,wlsUrl)
    print 'Conectado!'
except:
    print 'Erro ao conectar no AdminServer!'
    exit(exitcode=1)

try:
    cd('AppDeployments')
    apps=cmo.getAppDeployments()
    appEncontradas = 0
    
    for app in apps:
        # Verifica se é uma versão da aplicação (nome base ou versionado)
        if app.getApplicationName() == '' + appNome + '' or app.getName().startswith(appNome + '#'):
            appEncontradas = appEncontradas + 1
            
            # Tentar verificar estado de forma simples
            try:
                cd('domainConfig:/AppDeployments/'+app.getName()+'/Targets')
                myTargets=ls(returnMap='true')
                
                cd('domainRuntime:/AppRuntimeStateRuntime/AppRuntimeStateRuntime')
                for targetinst in myTargets:
                    try:
                        curState=cmo.getCurrentState(app.getName(),targetinst)
                        print 'Encontrada aplicação: ' + app.getName() + ' - Status: ' + curState
                    except:
                        print 'Encontrada aplicação: ' + app.getName() + ' - Status: UNKNOWN'
            except:
                print 'Encontrada aplicação: ' + app.getName() + ' - Status: ERROR'
    
    disconnect()
    exit()
    
except:
    print 'Erro ao validar deployment da aplicacao ' + appNome + '!'
    try:
        disconnect()
    except:
        pass
    exit(exitcode=1)