FROM ruby:3.4.8@sha256:998b24b17d0e8ac2a9974c11052cba9bb46f8ba519169969492181f262d27a58
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
