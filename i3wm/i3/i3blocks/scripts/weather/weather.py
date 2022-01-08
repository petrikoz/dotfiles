#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright 2019 Petr Zelenin (po.zelenin@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from pathlib import Path
import argparse
import configparser
import json
import urllib.request

BASE_DIR = Path(__file__).parent

ICONS = {
    '01d': '\ue30d',  # 
    '01n': '\ue32b',  # 
    '02d': '\ue30c',  # 
    '02n': '\ue379',  # 
    '03d': '\ue302',  # 
    '03n': '\ue37e',  # 
    '04d': '\ue312',  # 
    '04n': '\ue312',  # 
    '09d': '\ue309',  # 
    '09n': '\ue326',  # 
    '10d': '\ue308',  # 
    '10n': '\ue325',  # 
    '11d': '\ue30f',  # 
    '11n': '\ue32a',  # 
    '13d': '\ue30a',  # 
    '13n': '\ue327',  # 
    '50d': '\ue303',  # 
    '50n': '\ue346',  # 
}


def get_config(path):
    path = path

    config = configparser.ConfigParser()
    config.read(path)

    return config['OWM']


def get_data(config, cache=None):

    url = 'https://api.openweathermap.org/data/2.5/weather'

    _first = True
    sep = '?'
    for key, value in config.items():
        url += f'{sep}{key}={value}'
        if _first:
            _first = False
            sep = '&'

    response = urllib.request.urlopen(url)
    data = response.read()
    data = json.loads(data)

    if cache is not None:
        with open(cache, 'w', encoding='utf-8') as cache:
            json.dump(data, cache)

    return data


def get_current(data):
    weather = data['weather'][0]
    icon = ICONS.get(weather['icon'])

    main = data['main']
    temp = str(round(main['temp'])) + '°C'

    return f'{icon} {temp}'


def main(args):
    config = get_config(args.config)
    data = get_data(config, args.cache)

    current = get_current(data)
    print(current)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()

    default = BASE_DIR.joinpath('config.ini')
    parser.add_argument('-c', '--config', default=default,
                        help=f'Config path. Default: "{default.absolute()}"')

    parser.add_argument('--cache', default=None,
                        help=f'Path to store JSON-output of API.')

    main(parser.parse_args())
