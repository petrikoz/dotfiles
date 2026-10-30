FROM python:3.12-slim

# ****************************************************************

LABEL org.opencontainers.image.authors="Petr Zelenin (po.zelenin@gmail.com)"

# ****************************************************************

# psql
RUN apt-get update && apt-get install --no-install-recommends -y postgresql-common gnupg
RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
ARG PG_VERSION=18
RUN apt-get update && apt-get install --no-install-recommends -y postgresql-client-${PG_VERSION}

# ****************************************************************

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ****************************************************************

# HOME, доступный на запись любому пользователю (ptpython, ipython, кэши)
ENV HOME=/home/user
RUN mkdir -m 777 "$HOME"

# ****************************************************************

# устанавливаем Poetry
# зависимости ставим в системный Python без venv,
# чтобы они были доступны при запуске с произвольным UID (--user)
ENV POETRY_VIRTUALENVS_CREATE=false
RUN pip install poetry
RUN pip install ipdb ptpython

# создаём рабочий каталог
RUN mkdir /project
WORKDIR /project/

# копируем необходимые для сборки файлы
COPY poetry.lock pyproject.toml ./

# устанавливаем зависимости
RUN poetry install --no-root #--without=itcase  # если ITCase Common не в проекте

# если ITCase Common не в проекте
#COPY --from=itcase tcase-common /itcase/itcase-common
#RUN pip install /itcase/itcase-common

# ****************************************************************

ENTRYPOINT ["python", "manage.py"]

