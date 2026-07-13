FROM python:3.12-slim-bullseye

# ****************************************************************

LABEL org.opencontainers.image.authors="Petr Zelenin (po.zelenin@gmail.com)"

# ****************************************************************

ARG PG_VERSION=18

# ****************************************************************
# POSTGRESQL CLIENT

RUN apt-get update
RUN apt-get install --no-install-recommends -y postgresql-common gnupg
RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
RUN apt-get install --no-install-recommends -y postgresql-client-${PG_VERSION}

# ****************************************************************

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ****************************************************************

# устанавливаем Poetry
RUN pip install poetry

# создаём рабочий каталог
RUN mkdir /project
WORKDIR /project/

# копируем необходимые для сборки файлы
COPY poetry.lock pyproject.toml ./
# если ITCase Common не в проекте
#COPY docker-compose/django/itcase/itcase-common /itcase/itcase-common

# создаём пользователя для работы в контейнере
RUN useradd --create-home --user-group --shell /bin/bash project
RUN chown -R project:project /project /itcase
USER project

# устанавливаем зависимости
RUN poetry install --no-root #--without=itcase  # если ITCase Common не в проекте
RUN poetry run pip install ipdb ptpython
# если ITCase Common не в проекте
#RUN poetry run pip install -e /itcase/itcase-common

# ****************************************************************

ENTRYPOINT ["poetry", "run", "python", "manage.py"]

