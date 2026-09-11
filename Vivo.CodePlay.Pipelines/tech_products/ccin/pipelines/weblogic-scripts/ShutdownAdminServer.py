# Documentação: https://docs.oracle.com/middleware/1213/wls/WLSTC/reference.htm

import sys

username = sys.argv[1]
password = sys.argv[2] 
url = sys.argv[3]
name = sys.argv[4] # Exemplo: 'WLS_GPSCO_QA_Admin'
entityType = sys.argv[5] # Exemplo: 'Server'

try:
    print 'Conectando ao AdminServer...'
    connect(username, password, url)
    print 'Conectado ao AdminServer. Iniciando shutdown do ' + entityType + ': ' + name + '...'
    shutdown(name, entityType, ignoreSessions='true')
    print 'Shutdown finalizado com sucesso'
    disconnect()
    exit()
except WLSTException,e:
    print 'Erro durante a execução do Shutdown!'
    print e
    dumpStack()
    exit(exitcode=1)
