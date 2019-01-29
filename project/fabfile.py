# -*- coding: utf-8 -*-
#
# Copyright 2018 Petr Zelenin (po.zelenin@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from distutils.util import strtobool
import os

from fabric.api import env
from fabric.colors import cyan, yellow
from fabric.context_managers import lcd, settings
from fabric.decorators import task
from fabric.operations import local

env.compose = 'docker-compose'
env.db_service = 'postgres'
env.docker = 'docker'
env.manage = 'manage.py'
env.project = os.path.basename(os.path.dirname(__file__))
env.container = f'{env.project}-server'
env.services = ('redis', env.db_service)

command_psql = f'psql --username={env.project} --dbname={env.project}'


@task
def anaconda():
    command = '/opt/anaconda/anaconda_server/docker/start python 19360'
    return project_exec(command, options='--detach')


def bool_arg(arg):
    return bool(strtobool(str(arg)))


@task
def compose_bash(command, entrypoint=None):
    """Run Docker container with custom entrypoint (default: bash).

    Example: fab compose_bash:'ls -l'
    """
    entrypoint = entrypoint or '/bin/bash'

    return local(f'{env.compose} run --rm --entrypoint {entrypoint}'
                 f' {env.project} -c {command}')


@task
def django_exec(command, pdb=False):
    """Run any command as suffix for manage.py in project-server container.

    Ex.: django_exec:help -> python manage.py help
    """
    python = 'python'
    if bool_arg(pdb):
        python += ' -m ipdb -c continue'

    return project_exec(f'{python} {env.manage} {command}')


@task(default=True)
def django_server(recreate=False):
    """Start Django's development server."""
    container = get_container_id()

    if bool_arg(recreate):
        local(f'{env.compose} build')

        if container:
            local(f'{env.docker} rm -f {container}')
            container = None

    if not container:
        return local(f'{env.compose} run --name {env.container}'
                     f' --service-ports {env.project} python -Walways'
                     f' {env.manage} runserver 0.0.0.0:8000')

    if env.services:
        local(f'{env.compose} start {" ".join(env.services)}')

    return local(f'{env.docker} start --attach --interactive {container}')


@task
def django_shell():
    """Start Django's shell.

    Default use 'shell_plus' command via Django Extensions.
    """
    return django_exec('shell_plus')


def get_container_id(options='--all --quiet'):
    """Return ID of project-server container."""
    return local(f'{env.docker} ps {options} --filter=name={env.container}',
                 capture=True)


@task
def itcase_dev_update(folder='itcase-dev', brunch='develop'):
    """Update all ItCase Dev submodules for project.

    Used for directories structure:
        .
        |-- Dockerfile
        |-- docker-compose.yml
        |-- fabfile.py         <-- current file
        |-- src                <-- source code of project
        |   |-- .git
        |   `-- ...
        `-- third-party
            |-- third-party-module
            |-- third-party-module
            |-- ...
            `-- third-party-module
    """
    subdirs = local(f'find {folder}/ -maxdepth 1 -type d', capture=True)
    subdirs = subdirs.split()

    for subdir in subdirs[1:]:

        with lcd(subdir), settings(warn_only=True):
            print(cyan(subdir))
            local(f'git pull origin {brunch}')


@task
def loadsql(filepath):
    """Load data form SQL-file into DB.

    Args:
        filepath (string): Path to SQL-file.

    """
    command = (f'cat {filepath} |'
               f' {env.docker} exec -iu {env.db_service}'
               f' {env.project}-{env.db_service}')
    command += ' ' + command_psql

    return local(command)


@task
def project_exec(command, options='--interactive --tty', user=None):
    """Exec command in project-server container."""
    container = get_container_id(options='--quiet')
    if not container:
        print(yellow('You must run "django_server" first'))
        return

    if user is not None:
        options += f' --user {user}'

    return local(f'{env.docker} exec {options} {container} {command}')


@task
def psql(args=''):
    """Run utilite 'psql' into database service."""
    command = f'{env.compose} exec --user {env.db_service} {env.db_service}'
    command += ' ' + command_psql

    if args:
        command += args

    return local(command)


@task
def tmux():
    commands = [
        f'rename-window {env.project}',
        'send-keys fab Enter',
        'split-window -h',
        'send-keys "cd src" Enter',
        'send-keys "git foc" Enter',
        'split-window',
        'send-keys "ls -l" Enter',
        'last-pane',
    ]

    for command in commands:
        local(f'tmux {command}')
