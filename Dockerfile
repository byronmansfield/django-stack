FROM centos:centos7

LABEL maintainer="bmansfield <byron@byronmansfield.com>" \
    name="CentOS 7 Python-3.5 Django 2 Image" \
    Vendor="CentOS"

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
    LD_LIBRARY_PATH="/usr/local/lib" \
    DJANGO_SETTINGS_MODULE="mysite.settings" \
    EL_VERSION="7" \
    PYTHONUNBUFFERED=1 \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

#install basics
RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8 && \
    yum install --setopt=tsflags=nodocs -y centos-release-scl \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-${EL_VERSION}.noarch.rpm \
        https://centos7.iuscommunity.org/ius-release.rpm && \
    yum install --setopt=tsflags=nodocs -y \
        gcc \
        gcc-c++ \
        make \
        git \
        python-devel.x86_64 \
        python-pip \
        python35u \
        python35u-pip \
        python35u-devel \
        postgresql-devel \
        sqlite && \
    \
    pip install --upgrade pipenv==8.2.7 && \
    pip install virtualenv && \
    \
    # clean up
    yum --setopt=tsflags=nodocs -y update && \
    rm -rf /var/cache/yum && \
    yum clean all && \
    \
    # create django user and group
    mkdir -p /app && \
    groupadd -g 499 -r django && \
    useradd -u 499 -r -g django -d /app django

WORKDIR /app

#Add the django project code
COPY . /app/

# set up python 3.5 virtual env
RUN chown -R django:django . && \
    chmod -R 775 requirements.txt && \
    chmod -R 775 manage.py && \
    virtualenv -p python3.5 venv && \
    chown -R django:django venv && \
    chmod -R 775 venv && \
    venv/bin/pip3.5 install -r requirements.txt

USER django

#django port
EXPOSE 8000

#App command
CMD [ "python", "manage.py", "runserver", "0.0.0.0:8000" ]
