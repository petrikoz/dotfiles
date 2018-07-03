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

from fabric.api import env
from fabric.decorators import task
from fabric.operations import local

env.docker = 'docker'
env.compose = 'docker-compose'
env.project = 'project'
env.container = '%s-server' % env.project
env.db_service = 'postgres'
env.services = ('redis', env.db_service)


def get_container_id(options='--all --quiet'):
    """Return ID of project-server container."""
    prefix = '%s ps %s' % (env.docker, options)
    _filter = '--filter=name=%s' % env.container
    return local('%s %s' % (prefix, _filter), capture=True)


@task
def project_exec(command, options='--interactive --tty', user=None):
    """Exec command in project-server container."""
    from fabric.colors import yellow

    container_id = get_container_id(options='--quiet')
    if not container_id:
        print(yellow('You must run "django_server" first'))
        return

    if user is not None:
        options += ' --user %s' % user

    prefix = '%s exec %s %s' % (env.docker, options, container_id)

    return local('%s %s' % (prefix, command))


@task
def django_exec(command):
    """Run any command as suffix for manage.py in project-server container.

    Ex.: django_exec:help -> python manage.py help
    """
    return project_exec('python manage.py %s' % command)


@task(default=True)
def django_server(recreate=False):
    """Start Django's development server."""
    container_id = get_container_id()

    if recreate:
        local('%s build' % env.compose)

        if container_id:
            local('%s rm -f %s' % (env.docker, container_id))
            container_id = None

    if not container_id:
        options = '--name %s --service-ports' % env.container
        prefix = '%s run %s %s' % (env.compose, options, env.project)
        command = 'runserver 0.0.0.0:8000'
        return local('%s python -Walways manage.py %s' % (prefix, command))

    local('%s start %s' % (env.compose, ' '.join(env.services)))

    prefix = '%s start --attach --interactive' % env.docker
    return local('%s %s' % (prefix, container_id))


@task
def django_shell():
    """Start Django's shell.

    Default use 'shell_plus' command via Django Extensions.
    """
    return django_exec('shell_plus')


@task
def itcase_dev_update(folder='itcase-dev', git_brunch='develop'):
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
    from fabric.colors import cyan
    from fabric.context_managers import lcd, settings

    path = './%s' % folder

    output = local('find %s -maxdepth 1 -type l' % path, capture=True)

    for subdir in output.split():

        with lcd(subdir), settings(warn_only=True):
            print(cyan(subdir))
            local('git pull origin %s' % git_brunch)


@task
def compose_bash(command, entrypoint='/bin/bash'):
    """Run Docker container with custom entrypoint (default: bash).

    Example: fab compose_bash:'ls -l'
    """
    _entrypoint = ''
    if entrypoint:
        _entrypoint = '--entrypoint %s' % entrypoint

    prefix = '%s run --rm %s %s' % (env.compose, _entrypoint, env.project)
    return local('%s -c "%s"' % (prefix, command))


@task
def psql(args=''):
    """Run utilite 'psql' into database service."""
    prefix = '{compose} exec --user {service} {service}'
    prefix = prefix.format(compose=env.compose, service=env.db_service)

    return local('%s psql --dbname=%s %s' % (prefix, env.project, args))


@task
def loadsql(filepath):
    """Load data form SQL-file into DB.

    Args:
        filepath (string): Path to SQL-file.

    """
    _cat = 'cat %s' % filepath

    _exec = '{docker} exec -iu {db_service} {project}-{db_service}'
    _exec = _exec.format(docker=env.docker, db_service=env.db_service,
                         project=env.project)

    _psql = 'psql -U {project} -d {project}'
    _psql = _psql.format(project=env.project)

    command = '{cat} | {exec} {psql}'.format(cat=_cat, exec=_exec, psql=_psql)
    return local(command)

