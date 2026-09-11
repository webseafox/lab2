from jsonschema import validate
from jsonschema import exceptions
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("path_schema")
parser.add_argument('path_config_frontend')
parser.add_argument('path_allowed_list')

args = parser.parse_args()


def load_json_file(path_file):
    with open(f'{path_file}', 'r') as file:
        file_loaded = json.load(file)

    return file_loaded


def check_api_key(config_frontend, allowed_list):
    print(config_frontend)
    for security_profile in config_frontend['securityProfiles']:
        for device in security_profile['devices']:
            if (device['type'] == "apiKey" or device['type'] == "basic" or device['type'] == "passThrough") and config_frontend['name'] not in allowed_list:    
                print(
                    f'API {config_frontend["name"]} is not authorized to use api Key ')
                raise Exception


def validate_json_file(config_frontend, schema_validate):
    try:
        validate(instance=config_frontend, schema=schema_validate)
        print("Validation successfull")
    except exceptions.ValidationError:
        raise Exception


if __name__ == '__main__':
    schema = load_json_file(args.path_schema)
    config_frontend = load_json_file(args.path_config_frontend)
    allowed = load_json_file(args.path_allowed_list)

    validate_json_file(config_frontend, schema)
    check_api_key(config_frontend, allowed)
