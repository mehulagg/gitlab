FROM ruby:2.3

RUN wget -q https://get.docker.com/builds/Linux/x86_64/docker-1.12.1.tgz
RUN tar -zxf docker-1.12.1.tgz && mv docker/docker /usr/local/bin/docker
RUN sed -i "s/httpredir.debian.org/ftp.us.debian.org/" /etc/apt/sources.list

RUN apt-get update && apt-get install -y --force-yes \
      libqt5webkit5-dev qt5-qmake qt5-default build-essential xvfb git \
    && apt-get clean

ENV BUNDLE_PATH /usr/lib/bundle

COPY ./Gemfile* ./
RUN bundle install

WORKDIR /home/qa
