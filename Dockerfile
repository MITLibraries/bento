FROM ruby:3.4.8@sha256:95b22f0745feddf4f3e749840c2b41b568efa30234d6eca4537c1dd042850415
RUN mkdir /bento
WORKDIR /bento
COPY Gemfile /bento/Gemfile
COPY Gemfile.lock /bento/Gemfile.lock

RUN gem install bundler
RUN bundle config set without 'production'
RUN bundle install

COPY . /bento

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
