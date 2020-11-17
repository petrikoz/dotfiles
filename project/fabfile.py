# Copyright 2020 Petr Zelenin (po.zelenin@gmail.com)
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

psql = f'psql --username={env.project} --dbname={env.project}'


@task
def db_dump(filepath='/tmp-host/sql/local.sql'):
    """Dump data form DB into SQL-file.

    Args:
        filepath (string): Path to SQL-file.

    """
    pg_dump = (f'pg_dump -U {env.project} -d {env.project} -f {filepath}'
               ' -bcOv --column-inserts')
    command = f' {env.compose} exec {env.db_service} {pg_dump}'

    return local(command)


@task
def db_loadsql(filepath):
    """Load data form SQL-file into DB.

    Args:
        filepath (string): Path to SQL-file.

    """
    command = (f'cat {filepath} |'
               f' {env.docker} exec -iu {env.db_service}'
               f' {env.project}-{env.db_service}'
               f' {psql}')

    return local(command)


@task
def db_reset():
    """Recreate container for database service."""
    suffixes = ('stop', f'rm -f {env.db_service}', f'up -d {env.db_service}')

    return local(' && '.join(f'{env.compose} {suffix}' for suffix in suffixes))


@task
def db_shell(args=''):
    """Run utilite 'psql' into database service."""
    command = f'{env.compose} exec --user {env.db_service} {env.db_service}'
    command += f' {psql}'

    if args:
        command += args

    return local(command)


@task
def dj_exec(command, pdb=False):
    """Run any command as suffix for manage.py in project-server container."""
    python = 'python'
    if get_bool(pdb):
        python += ' -m ipdb -c continue'

    project_exec(f'{python} {env.manage} {command}')


@task(default=True)
def dj_server(recreate=False):
    """Start Django's development server."""
    container = get_container_id()

    if get_bool(recreate):
        local(f'{env.compose} build')

        if container:
            local(f'{env.docker} rm -f {container}')
            container = None

    if not container:
        return local(f'{env.compose} run --name {env.container}'
                     f' --service-ports {env.project} python -Walways'
                     f' {env.manage} runserver 0.0.0.0:8000')

    services = get_compose_services()
    if services:
        local(f'{env.compose} start {services}')

    local(f'{env.docker} start {container}')
    st_lsp()

    return local(f'{env.docker} attach {container}')


@task
def dj_shell():
    """Run 'shell_plus' command from Django Extensions."""
    return dj_exec('shell_plus')


def get_bool(arg):
    return bool(strtobool(str(arg)))


def get_compose_services():
    services = local(f'{env.compose} config --services', capture=True)
    services = services.split('\n')
    services.remove(env.project)
    return ' '.join(services)


def get_container_id(options='--all --quiet'):
    """Return ID of project-server container."""
    return local(f'{env.docker} ps {options} --filter=name={env.container}',
                 capture=True)


@task
def itcase_dev_update(folder='itcase-dev', branch=None):
    """Update all ItCase Dev submodules.

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
    branch = branch or '"$(git rev-parse --abbrev-ref HEAD)"'

    subdirs = local(f'find {folder}/ -maxdepth 1 -type d', capture=True)
    subdirs = subdirs.split()

    for subdir in subdirs[1:]:

        with lcd(subdir), settings(warn_only=True):
            print(cyan(subdir))
            local(f'git pull origin {branch}')


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
def st_lsp():
    """Run Python Language Server for Sublime Text."""
    command = 'pyls --tcp --host 0.0.0.0 --port 19360'
    project_exec(command, options='--detach')


@task
def tmux():
    """Configure TMUX's current window for project."""
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
