FROM python:3.8

MAINTAINER Petr Zelenin (po.zelenin@gmail.com)

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

### Project
RUN mkdir /project
RUN pip install poetry

COPY src/poetry.lock src/pyproject.toml /project/
RUN cd /project \
    && poetry install --no-root --without=itcase,prod \
    && poetry run pip install -e /itcase/itcase-common \
    && poetry run pip install ipdb ptpython

WORKDIR /project/

ENTRYPOINT ["poetry", "run", "python", "manage.py"]
