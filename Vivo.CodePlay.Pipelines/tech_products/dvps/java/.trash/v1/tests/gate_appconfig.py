import os
def get_varname(var_name):
  os.getenv(var_name)

def get_bool(var_name, default = "false"):
  """Retrieve environment variable or return 'false' if it doesn't exist or is empty."""
  return os.getenv(var_name, default).lower() in ("yes", "true", "t", "1")

# Variáveis principais
USE_FORTIFY = False
USE_CONVISO = False
USE_CHECKMARX = False
SKIP_GATE = False
USE_APPCONFIG = get_bool("APP_CONFIGURATION_ENABLED") == True
GLOBAL_FORTIFY = get_bool(os.getenv("KEY_GLOBAL_FORTIFY")) == True
PROJECT_FORTIFY = get_bool(os.getenv("KEY_PROJECT_FORTIFY")) == True
COMPONENT_FORTIFY = get_bool(os.getenv("KEY_COMPONENT_FORTIFY")) == True
GLOBAL_CONVISO = get_bool(os.getenv("KEY_GLOBAL_CONVISO")) == True
PROJECT_CONVISO = get_bool(os.getenv("KEY_PROJECT_CONVISO")) == True
COMPONENT_CONVISO = get_bool(os.getenv("KEY_COMPONENT_CONVISO")) == True
GLOBAL_CHECKMARX = get_bool(os.getenv("KEY_GLOBAL_CHECKMARX")) == True
PROJECT_CHECKMARX = get_bool(os.getenv("KEY_PROJECT_CHECKMARX")) == True
COMPONENT_CHECKMARX = get_bool(os.getenv("KEY_COMPONENT_CHECKMARX")) == True
GLOBAL_SKIP_SECURITY_GATE = get_bool(os.getenv("KEY_GLOBAL_SKIP_SECURITY_GATE")) == True
PROJECT_SKIP_SECURITY_GATE = get_bool(os.getenv("KEY_PROJECT_SKIP_SECURITY_GATE")) == True
COMPONENT_SKIP_SECURITY_GATE = get_bool(os.getenv("KEY_COMPONENT_SKIP_SECURITY_GATE")) == True

if USE_APPCONFIG:
  # FORTIFY SETTINGS
  USE_FORTIFY = (GLOBAL_FORTIFY and PROJECT_FORTIFY and COMPONENT_FORTIFY)
  # CONVISO SETTINGS
  USE_CONVISO = (GLOBAL_CONVISO and PROJECT_CONVISO and COMPONENT_CONVISO and USE_FORTIFY)
  # CHECKMARX SETTINGS
  if GLOBAL_CHECKMARX and PROJECT_CHECKMARX and COMPONENT_CHECKMARX:
    USE_CHECKMARX = True
    USE_FORTIFY = False
    USE_CONVISO = False

  # SKIP_SECURITY_GATE SETTINGS
  SKIP_GATE = (GLOBAL_SKIP_SECURITY_GATE or PROJECT_SKIP_SECURITY_GATE or COMPONENT_SKIP_SECURITY_GATE)

else:
  
  # Alternativa se USE_APPCONFIG não é "true"
  USE_CHECKMARX = get_bool("USE_CHECKMARX") == True
  SKIP_GATE = get_bool("SKIP_SECURITY_GATE") == True

  SKIP_SECURITY = get_bool("skip_security") == True
  SKIP_FORTIFY_GATE = get_bool("skip_fortify_gate") == True
  SKIP_CONVISO_SECURITY_GATE = get_bool("SKIP_CONVISO_SECURITY_GATE") == True

  if not SKIP_SECURITY:
    if not SKIP_FORTIFY_GATE:
      USE_FORTIFY = True
    if not SKIP_CONVISO_SECURITY_GATE:
      USE_CONVISO = True
    if USE_CHECKMARX:
      USE_FORTIFY = False
      USE_CONVISO = False
  else:
    USE_CHECKMARX = False

# def set_variable(name, value):
#   print(f"task.setvariable {name}, {value}")

set_variable('USE_APPCONFIG', str(USE_APPCONFIG).lower())
set_variable('GLOBAL_FORTIFY', str(GLOBAL_FORTIFY).lower())
set_variable('PROJECT_FORTIFY', str(KEY_PROJECT_FORTIFY).lower())
set_variable('COMPONENT_FORTIFY', str(COMPONENT_FORTIFY).lower())
set_variable('GLOBAL_CONVISO', str(GLOBAL_CONVISO).lower())
set_variable('PROJECT_CONVISO', str(PROJECT_CONVISO).lower())
set_variable('COMPONENT_CONVISO', str(COMPONENT_CONVISO).lower())
set_variable('GLOBAL_CHECKMARX', str(GLOBAL_CHECKMARX).lower())
set_variable('PROJECT_CHECKMARX', str(PROJECT_CHECKMARX).lower())
set_variable('COMPONENT_CHECKMARX', str(COMPONENT_CHECKMARX).lower())
set_variable('GLOBAL_SKIP_SECURITY_GATE', str(GLOBAL_SKIP_SECURITY_GATE).lower())
set_variable('PROJECT_SKIP_SECURITY_GATE', str(PROJECT_SKIP_SECURITY_GATE).lower())
set_variable('COMPONENT_SKIP_SECURITY_GATE', str(COMPONENT_SKIP_SECURITY_GATE).lower())

# Variáveis de saída para Azure Pipelines
set_variable('USE_FORTIFY', str(USE_FORTIFY).lower())
set_variable('USE_CONVISO', str(USE_CONVISO).lower())
set_variable('USE_CHECKMARX', str(USE_CHECKMARX).lower())
set_variable('SKIP_SECURITY_GATE', str(SKIP_GATE).lower())