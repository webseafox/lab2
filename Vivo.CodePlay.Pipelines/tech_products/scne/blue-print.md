# Pipeline Blue Print

SCNE - SCIENCE

## Alinhamento 26/06/25 11h00

### Participantes da Reunião

| Nome | Email | Entrada | Saída | Duração | Papel |
|------|-------|---------|--------|---------|--------|
| Leonardo Torres Montero | `leonardo.tmontero@telefonica.com` | 11:05 | 11:52 | 47min 4s | Organizador |
| Paulo Everton Dentello | `paulo.dentello@fcamara.com` | 11:05 | 11:52 | 46min 52s | Apresentador |
| Jefferson Itajahy Dos Santos | `jitajahy@minsait.com` | 11:07 | 11:52 | 44min 38s | Apresentador |
| Ronaldo Pereira Da Silva | `rpereira@minsait.com` | 11:24 | 11:52 | 28min 16s | Apresentador |
| Ellen Ferreira Cavalcante | `efcavalcante@minsait.com` | 11:24 | 11:52 | 28min 1s | Apresentador |
| Diego Jacynto Garcia Rodriguez Pereira Da Silva | `diego.silv@telefonica.com` | 11:41 | 11:52 | 10min 55s | Apresentador |

### Resumo da Reunião

- Estava na bolha Jenkins
- Não teria pipeline no Azure DevOps - Só teria se fosse solicitado. (Jessica Costa e Perin)
  - Forum DevOps Labs
- Na bolha jenkins não estava publicando no nexus (começo do ano)
- Problema na bolha jenkins
- Havia aberto incidente (antes da migração e voltou a funcionar, agora parou de novo).
- Esta no processo novo até hoje
- Mesmo Problema atual de não replicar no nexus 9 meses atrás.
- INC2494053
- Não estava na bolha jenkins, estava em um outro jenkins.
- Era bom o pessoal de sustentação saber fazer pipe. Trazer eles para o CodePlay.

Opções:

- :x: Voltar a funcionar a bolha Jenkins (Houve mudança ou está com falha?) - Nunca esteve na Bolha.
  - Time quer voltar isso
  - Foi Desligado
  - Na verdade está em outro jenkins.
  - Foi despriorado pelo time de OSS (Perin)
- :ok: Criar pipeline no Azure DevOps
  - DevOps acha melhor criar pipe no AZDO
  - Fazer uma volta com os times

Existe alguma impeditivo para estar na bolha jenkins?

- Provavelmente não, questão de priorização.

### Próximos passos

Reunião com o time de DevOps corp pra entende por que não foi migrado para AZDO.

Lado DevOps:

- `paulo.dentello@fcamara.com`
- `leonardo.tmontero@telefonica.com`
- `diego.silv@telefonica.com`
- `joao.rinardo@telefonica.com`
- `wesley.beserra@certsys.com.br` (Realizou o atendimento 9 meses atrás)

Diego vai trocar uma ideia com sustentação para aproximar do CodePlay.

## Alinhamento 27/06/25 11h00

- Alinhar construção do pipe com OSS Vivo
- Luan forneceu contexto para o Juliano
- Sustentação nao faz pipeline
- OSS tem um recurso alocado para criar os pipes.
- Vão verificar internamente OSS + SCIENCE e apoio de DevOps para criar o pipe.
- Luan vai passar a lista para Juliano sobre a construção do pipe.
- Juliano vai puxar a proxima call

## Pipeline no Azure DevOps

- Java
- WebLogic
