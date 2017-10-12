FROM ruby:2.4

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

COPY . /bento/

WORKDIR /bento
RUN bundle install
RUN bundle exec rake db:setup && bundle exec rake db:migrate

EXPOSE 3000

ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "s", "-p", "3000", "-b", "0.0.0.0"]
