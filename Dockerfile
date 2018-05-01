FROM centos:latest
MAINTAINER Jozsef Lazar <jozsef.gabor.lazar@gmail.com>

RUN yum update -y

RUN yum install -y ruby python python-devel gcc
RUN gem install bundler
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py
RUN yum clean all

RUN mkdir /usr/app
WORKDIR /usr/app

COPY . /usr/app
RUN ln -s /usr/app/.ansible.cfg /root/.ansible.cfg
RUN bundle install --no-cache
RUN pip install -r requirements.txt --no-cache-dir
