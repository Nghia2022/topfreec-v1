FROM golang:1.15 AS entrykit
RUN go get -v -ldflags "-s -w" github.com/progrium/entrykit/cmd

FROM angellistci/dockerize:v0.6.1 AS dockerize

FROM ruby:3.2.2-bullseye

ENV APP=/app \
    LANG=C.UTF-8

COPY --from=entrykit /go/bin/cmd /bin/entrykit
RUN entrykit --symlink

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
  && wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list \
  && apt-key update \
  && apt-get update -qq \
  && apt-get install --no-install-recommends --allow-unauthenticated -y build-essential postgresql-client-12 nodejs yarn fonts-noto-cjk vim python2 less \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


COPY --from=dockerize /dockerize /usr/local/bin/dockerize

RUN useradd -m --shell /bin/bash --uid 1000 ruby
RUN mkdir $APP && mkdir -p $APP/tmp/cache $APP/node_modules && chown ruby:ruby $APP $APP/tmp $APP/tmp/cache $APP/node_modules && mkdir -p /home/ruby/.cache/yarn && chown ruby /home/ruby/.cache /home/ruby/.cache/yarn

USER ruby

WORKDIR $APP

ENV EDITOR vim

RUN bundle config --global retry 5 \
  && bundle config --global jobs 4

ENTRYPOINT [ \
    "prehook", \
      "ruby -v",\
      "bundle install", \
      "yarn install --check-files", \
      "rm -f tmp/pids/server.pid", \
      "--" \
      ]
