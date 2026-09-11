import sys

wlsAdmin = sys.argv[1]
wlsPassword = sys.argv[2]
wlsUrl = sys.argv[3]

try:
    print('Conectando no AdminServer.....')
    connect(wlsAdmin,wlsPassword,wlsUrl)
    print('Conectado com sucesso!')
    print("Desconectando...")
    exit()
    print("Desconectado com sucesso!")
except WLSTException,e:
    print('[ERRO] Problema ao conectar no AdminServer', e)
    dumpStack()
    exit(exitcode=1)
