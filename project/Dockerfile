FROM python:latest

MAINTAINER Petr Zelenin (po.zelenin@gmail.com)

### Global
RUN pip install --upgrade pip ptpython ipdb
RUN pip install --upgrade django-extensions

### Project
RUN mkdir /code
COPY ./src/requirements.txt /code/
RUN pip install -r /code/requirements.txt

### User
ENV HOME_USER user
ENV HOME_PASS password

RUN useradd -m -s /bin/bash ${HOME_USER}
RUN echo "${HOME_USER}:${HOME_PASS}" | chpasswd

RUN chown -R ${HOME_USER}:${HOME_USER} /code

USER user

### ENTRYPOINT
WORKDIR /code/

