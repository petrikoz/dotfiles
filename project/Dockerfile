FROM python:3.8

MAINTAINER Petr Zelenin (po.zelenin@gmail.com)

# Install custom soft. Ex. WKHTMLTOPDF
#COPY ./tmp/wkhtmltox.deb /tmp/wkhtmltox.deb
#RUN apt-get update
#RUN apt-get install -y /tmp/wkhtmltox.deb

### Global
RUN pip install --upgrade ipdb pip ptpython python-language-server==0.36.2
RUN pip install --upgrade django-debug-toolbar django-extensions

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
