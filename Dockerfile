FROM ruby:2.1.10

ENV APP_HOME=/myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

RUN apt-get update -qq \
    && apt-get install -y \
      build-essential \
      libpq-dev \
      nodejs

# Make it possible to run rspec, rake, bundle, etc. from a shell session
# in the container without prepending bundle exec
ENV PATH $PATH:$APP_HOME/bin

COPY Gemfile* $APP_HOME/

RUN bundle install

# Copy files last so that if files have changed, the other build steps
# will not be invalidated and can still use the cache.
COPY . $APP_HOME/
