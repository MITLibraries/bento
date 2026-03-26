FROM ruby:3.4.9@sha256:ec3a4b139bb18412233444c725069d3134c58d8855efc2d9d92aac593e4bc0fb
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
