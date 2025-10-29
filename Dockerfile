FROM ruby:3.4.7@sha256:85792c7c1adcb5c304ae668d0482f7213f22794ddd8a7df1f5a92da002eee662
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
