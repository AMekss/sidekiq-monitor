FROM ruby:2.5.1-alpine3.7

ENV LANG C.UTF-8
WORKDIR /app

COPY Gemfile* ./

RUN apk update && apk add --no-cache build-base \
  && bundle install --without development test \
  && apk del --purge build-base

COPY . ./

EXPOSE 80

CMD ["bundle", "exec", "rackup", "-o0.0.0.0", "-p9292"]
