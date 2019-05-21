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
    'clear-day': '\ue30d',
    'clear-night': '\ue32b',
    'cloudy': '\ue312',
    'fog': '\ue313',
    'partly-cloudy-day': '\ue302',
    'partly-cloudy-night': '\ue37e',
    'rain': '\ue318',
    'sleet': '\ue316',
    'snow': '\ue31a',
    'wind': '\ufa9c',
}


def get_config(path):
    path = path

    config = configparser.ConfigParser()
    config.read(path)

    return config['ARGS'], config['OPTIONS']


def get_data(key, latitude, longitude, cache=None, **options):

    url = f'https://api.darksky.net/forecast/{key}/{latitude},{longitude}'

    _first = True
    sep = '?'
    for key, value in options.items():
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
    icon = ICONS.get(data['icon'])
    temp = str(round(data['temperature'])) + '°C'

    return f'{icon}  {temp}'


def main(args):
    _args, options = get_config(args.config)
    data = get_data(_args['key'], _args['latitude'], _args['longitude'],
                    args.cache, **options)

    current = get_current(data['currently'])
    print(current)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()

    default = BASE_DIR.joinpath('config.ini')
    parser.add_argument('-c', '--config', default=default,
                        help=f'Config path. Default: "{default.absolute()}"')

    parser.add_argument('--cache', default=None,
                        help=f'Path to store JSON-output of API.')

    main(parser.parse_args())
