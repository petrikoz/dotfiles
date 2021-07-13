# Copyright 2021 Petr Zelenin (po.zelenin@gmail.com)
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
"""Local tasks.

For details see: https://docs.pyinvoke.org/en/stable/
"""

from pathlib import Path
from os import getenv

from invoke import task

DIR_BASE = Path(__file__).parent.absolute()
DIR_SRC = DIR_BASE.joinpath('src')

POSTGRES_ROOT = 'postgres'

PROJECT = getenv('PROJECT', DIR_BASE.stem)


@task(
    help={
        'filepath': ('Path to save SQL-file.'
                     ' Default: {DIR_BASE}/tmp/sql/prod.sql'),
        'dbname': f'Database name. Default: {PROJECT}',
        'user': f'User for "pg_dump". Default: {PROJECT}'
    })
def db_dump(c, filepath='tmp/sql/local.sql', dbname=PROJECT, user=PROJECT):
    """Dump data form RDBMS PostgreSQL into SQL-file."""
    filepath = Path(filepath)
    if not filepath.is_absolute():
        filepath = DIR_BASE.joinpath(filepath).absolute()
        print(f'Save file "{filepath}"')
    c.run(f'pg_dump -U {user} -d {dbname} -f {filepath} -bcOv')


@task(
    help={
        'filepath': 'Path to SQL. Example: tmp/sql/prod.sql',
        'dbname': f'Database name. Default: {PROJECT}',
        'user': f'User for "psql". Default: {PROJECT}'
    })
def db_loadsql(c, filepath, dbname=PROJECT, user=PROJECT):
    """Load data form SQL-file into RDBMS PostgreSQL."""
    filepath = Path(filepath)
    if not filepath.is_absolute():
        filepath = DIR_BASE.joinpath(filepath).absolute()
        print(f'Load file "{filepath}"')
    c.run(f'psql -U {user} -d {dbname} -f {filepath} --echo-errors')


@task(
    help={
        'dbname': f'Database name. Default: {PROJECT}',
        'owner': f'Database owner. Default: {PROJECT}',
        'owner_password': ('Password for owner role.'
                           f' Default: {PROJECT}-password'),
        'user': f'User for "psql". Default: {POSTGRES_ROOT}',
        'loadsql': ('Path to SQL-file wich will be load after.'
                    ' Example: tmp/sql/prod.sql')
    })
def db_reset(c,
             dbname=PROJECT,
             owner=PROJECT,
             owner_password=f'{PROJECT}-password',
             user=POSTGRES_ROOT,
             loadsql=None):
    """Re/create database for project in RDBMS PostgreSQL."""
    queries = (
        f'DROP DATABASE IF EXISTS {dbname};',
        f'DROP ROLE IF EXISTS {owner};',
        f"CREATE ROLE {owner} WITH LOGIN PASSWORD '{owner_password}';",
        f'CREATE DATABASE {dbname} WITH OWNER {owner};',
        f'GRANT ALL ON DATABASE {dbname} TO {owner};',
    )
    for query in queries:
        c.run(f'psql -U {user} -c "{query}"')

    if isinstance(loadsql, str):
        db_loadsql(c, loadsql, dbname=dbname, user=owner)


@task(
    help={
        'dbname': f'Database name. Default: {PROJECT}',
        'user': f'User for "psql". Default: {PROJECT}'
    })
def db_shell(c, dbname=PROJECT, user=PROJECT):
    """Run 'psql'."""
    c.run(f'psql -U {user} -d {dbname}')


@task(
    help={
        'cmd': "Any available Django's management command. Example: help",
        'pdb': 'Enable `ipdb` for command'
    })
def dj_exec(c, cmd, pdb=False):
    """Run any available Django's management command"""
    python = 'python'
    if pdb:
        python += ' -m ipdb -c continue'
    with c.cd(DIR_SRC):
        c.run(f'{python} manage.py {cmd}', pty=True)


@task(default=True,
      help={
          'addr': 'IP address. Default: 127.0.0.1',
          'port': 'Port on IP address. Default: 8000'
      })
def dj_server(c, addr='127.0.0.1', port=8000):
    """Start Django's development server."""
    docker_redis_cli(c, 'FLUSHALL')
    dj_exec(c, f'runserver {addr}:{port}')


@task
def dj_shell(c):
    """Run 'shell_plus' command from Django Extensions."""
    dj_exec(c, 'shell_plus')


def docker_get_image_tag(c, image):
    result = c.run(f'docker images {image} --format "{{{{.Tag}}}}"', hide=True)
    return result.stdout


@task
def docker_elasticsearch(c, image='elasticsearch'):
    """Run Docker's elasticsearch container."""

    _container = c.run(f'docker ps -qf "name={image}"', hide=True)
    if _container.stdout:
        c.run(f'docker kill {image}', hide=True)

    tag = docker_get_image_tag(c, image)
    c.run(
        'docker run -d -p 127.0.0.1:9200:9200 -p 127.0.0.1:9300:9300'
        ' -e "discovery.type=single-node"'
        f' --name {image} --rm {image}:{tag}',
        echo=True,
        hide='stdout')


@task
def docker_redis_cli(c, cmd=None, image='redis'):
    """Exec 'redis-cli' in Docker's redis container."""

    result = c.run(f'docker ps -qf "name={image}"', hide=True)
    if not result.stdout:
        tag = docker_get_image_tag(c, image)
        c.run(f'docker run -d -p 127.0.0.1:6379:6379 --name {image}'
              f' --rm {image}:{tag}')

    pty = cmd is None
    tty = ''
    if pty:
        cmd = ''
        tty = '-it'

    c.run(f'docker exec {tty} {image} redis-cli {cmd}',
          echo=True,
          hide='stdout',
          pty=pty)


@task
def pip_install_requirements(c):
    """Install requirements for project."""
    with c.cd(DIR_BASE):
        c.run('pip install -r requirements-local.txt')
    with c.cd(DIR_SRC):
        c.run('pip install -r requirements.txt')
