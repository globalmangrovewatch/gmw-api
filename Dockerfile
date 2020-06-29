FROM ruby:2.6.3
LABEL maintainer="hello@vizzuality.com"

ARG env

ENV RAILS_ENV $env
ENV RACK_ENV $env

# Install dependencies
RUN apt update && apt install -y \
        build-essential \
        bash \
        postgresql postgresql-contrib \
    && apt clean

WORKDIR /usr/src/api
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5
ADD . /usr/src/api

EXPOSE 3000
CMD bundle exec puma -C config/puma.rb
# ENTRYPOINT [ "./entrypoint.sh" ]
