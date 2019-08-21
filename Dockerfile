FROM ruby:2.3-stretch

WORKDIR /home/app

RUN \
    curl -sL https://deb.nodesource.com/setup_6.x | bash -  && \
    apt-get update && \
    apt-get --no-install-recommends -y install git tzdata make g++ wget curl inotify-tools nodejs && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apt/*

ENV PATH=./node_modules/.bin:$PATH \
    HOME=/home/app

RUN set -ex \
    && mkdir -p /home/app/tmp/cache \
    && mkdir -p /home/app/tmp/pids \
    && mkdir -p /home/app/tmp/sockets \
    && mkdir -p /var/bytestand \
    && mkdir -p /var/log/bytestand

RUN gem install bundler && \
    npm config set unsafe-perm true && \
    npm install -g yarn 

ADD Gemfile* /home/app/

RUN bundle install --jobs 10

ADD yarn* package.json /home/app/

RUN yarn install

ADD . /home/app

RUN REDIS_URL="redis://localhost:6379" DATABASE_URL="postgres://127.0.0.1:5432" NODE_ENV=production RAILS_ENV=production bundle exec rails assets:precompile

RUN ln -sf /dev/console /home/app/log/production.log

CMD ["/bin/sh"]