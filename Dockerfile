FROM ruby:3.4.8@sha256:40b615a7ae6859d6ff82cc389e9b1ea673f2683a035da2c48e1ef203f7c1fe52
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
