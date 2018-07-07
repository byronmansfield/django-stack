FROM bmansfield/django-base:latest

LABEL maintainer="Byron Mansfield <byron@byronmansfield.com>" \
    name="Python 3.5 Django 2 Project Image"

#Add in image metadata
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG REPO
ARG VENDOR
ARG ENVIRONMENT

#Set environment vars
ENV BUILD_DATE=${BUILD_DATE} \
    VERSION=${VERSION} \
    VCS_URL=${VCS_URL} \
    VCS_REF=${VCS_REF} \
    REPO=${REPO} \
    VENDOR=${VENDOR} \
    ENVIRONMENT=${ENVIRONMENT} \
    DJANGO_SETTINGS_MODULE="mysite.settings" \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY . /app/

USER root

# set up python 3.5 virtual env
RUN chown -R django:django . && \
    chmod -R 775 requirements.txt && \
    chmod -R 775 manage.py && \
    \
    # setup virtual env
    virtualenv -p python3.5 venv && \
    chown -R django:django venv && \
    chmod -R 775 venv && \
		\
    # setup supervisor
    mv supervisord.conf /etc/supervisord.conf && \
    mv supervisor.conf /etc/supervisord.d/ && \
    chown django:django /etc/supervisord.conf && \
		chown -R django:django /etc/supervisord.d/ && \
    chmod 775 /etc/supervisord.conf && \
    chmod -R 775 /etc/supervisord.d/ && \
		\
    # Set up static assets folder
    mkdir -p /app/static && \
    chown -R django:django /app/static && \
    chmod -R 775 /app/static && \
		\
    # Install Python packages
    venv/bin/pip3.5 install -r requirements.txt

USER django

EXPOSE 8000
