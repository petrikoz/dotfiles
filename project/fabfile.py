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

from fabric.api import env
from fabric.colors import cyan, yellow
from fabric.context_managers import lcd, settings
from fabric.decorators import task
from fabric.operations import local

env.compose = 'docker-compose'
env.db_service = 'postgres'
env.docker = 'docker'
env.manage = 'manage.py'
env.project = 'project'
env.container = '{project}-server'.format(**{'project': env.project})
env.services = ('redis', env.db_service)


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
    _command = '{compose} run --rm --entrypoint {entrypoint} {project}'
    _command += ' -c {command}'
    _command = _command.format(**{
        'command': command,
        'compose': env.compose,
        'entrypoint': entrypoint or '/bin/bash',
        'project': env.project,
    })

    return local(_command)


@task
def django_exec(command, pdb=False):
    """Run any command as suffix for manage.py in project-server container.

    Ex.: django_exec:help -> python manage.py help
    """
    python = 'python'
    if bool_arg(pdb):
        python += ' -m ipdb -c continue'

    _command = '{python} {manage} {command}'
    _command = _command.format(**{
        'command': command,
        'manage': env.manage,
        'python': python,
    })

    return project_exec(_command)


@task(default=True)
def django_server(recreate=False):
    """Start Django's development server."""
    container = get_container_id()

    if bool_arg(recreate):
        local('{compose} build'.format(**{'compose': env.compose}))

        if container:
            command = '{docker} rm -f {container}'
            command = command.format(**{
                'container': container,
                'docker': env.docker,
            })
            local(command)
            container = None

    if not container:
        command = '{compose} run --name {container} --service-ports'
        command += ' {project} python -Walways {manage}'
        command += ' runserver 0.0.0.0:8000'
        command = command.format(**{
            'compose': env.compose,
            'container': env.container,
            'manage': env.manage,
            'project': env.project,
        })
        return local(command)

    if env.services:
        command = '{compose} start {services}'
        command = command.format(**{
            'compose': env.compose,
            'services': ' '.join(env.services),
        })
        local(command)

    command = '{docker} start --attach --interactive {container}'
    command = command.format(**{
        'container': container,
        'docker': env.docker,
    })
    return local(command)


@task
def django_shell():
    """Start Django's shell.

    Default use 'shell_plus' command via Django Extensions.
    """
    return django_exec('shell_plus')


def get_container_id(options='--all --quiet'):
    """Return ID of project-server container."""
    command = '{docker} ps {options} --filter=name={container}'
    command = command.format(**{
        'container': env.container,
        'docker': env.docker,
        'options': options,
    })
    return local(command, capture=True)


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
    command = 'find {folder}/ -maxdepth 1 -type d'
    command = command.format(**{'folder': folder})

    subdirs = local(command, capture=True)
    subdirs = subdirs.split()

    for subdir in subdirs[1:]:

        with lcd(subdir), settings(warn_only=True):
            print(cyan(subdir))
            local('git pull origin {brunch}'.format(**{'brunch': brunch}))


@task
def loadsql(filepath):
    """Load data form SQL-file into DB.

    Args:
        filepath (string): Path to SQL-file.

    """
    command = 'cat {filepath} |'
    command += ' {docker} exec -iu {service} {project}-{service}'
    command += ' psql -U {project} -d {project}'
    command = command.format(**{
        'docker': env.docker,
        'filepath': filepath,
        'project': env.project,
        'service': env.db_service,
    })

    return local(command)


@task
def project_exec(command, options='--interactive --tty', user=None):
    """Exec command in project-server container."""
    container = get_container_id(options='--quiet')
    if not container:
        print(yellow('You must run "django_server" first'))
        return

    if user is not None:
        options += ' --user {user}'.format(**{'user': user})

    _command = '{docker} exec {options} {container} {command}'
    _command = _command.format(**{
        'command': command,
        'container': container,
        'docker': env.docker,
        'options': options,
    })

    return local(_command)


@task
def psql(args=''):
    """Run utilite 'psql' into database service."""
    command = '{compose} exec --user {service} {service}'
    command += ' psql --dbname={project}'
    if args:
        command += args
    command = command.format(**{
        'compose': env.compose,
        'project': env.project,
        'service': env.db_service,
    })

    return local(command)

