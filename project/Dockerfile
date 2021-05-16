FROM python:3.8

MAINTAINER Petr Zelenin (po.zelenin@gmail.com)

### System-wide requirements
# Ex. WKHTMLTOPDF
#RUN curl -L https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb -o /tmp/wkhtmltox.deb
# or
#COPY ./tmp/wkhtmltox.deb /tmp/wkhtmltox.deb
#RUN apt-get update && apt-get install -y /tmp/wkhtmltox.deb

### User
RUN useradd -m -s /bin/bash user \
    && echo "user:password" | chpasswd

### Project
RUN mkdir /code \
    && chown -R user:user /code
USER user

## Python
# Development requirements
RUN pip install --upgrade \
    ipdb pip ptpython 'python-language-server[yapf]==0.36.2' \
    django-debug-toolbar django-extensions

# Project requirements
COPY ./src/requirements.txt /code/
RUN pip install -r /code/requirements.txt

### Entrypoint
WORKDIR /code/
