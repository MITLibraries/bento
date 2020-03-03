[![Build Status](https://travis-ci.org/MITLibraries/bento.svg?branch=master)](https://travis-ci.org/MITLibraries/bento)
[![Coverage Status](https://coveralls.io/repos/github/MITLibraries/bento/badge.svg?branch=master)](https://coveralls.io/github/MITLibraries/bento?branch=master)
[![Depfu](https://badges.depfu.com/badges/4e708126f48dfe5edf3b09b1dbc2854b/overview.svg)](https://depfu.com/github/MITLibraries/bento)
[![Code Climate](https://codeclimate.com/github/MITLibraries/bento/badges/gpa.svg)](https://codeclimate.com/github/MITLibraries/bento)

# MIT Bento

## What is this?

MIT Bento aims to search multiple data sources and return a summary of results
to aid a user towards a successful discovery experience.

It currently searches Ebsco Discovery Services API (EDS) and Google Custom
Search API. Appropriate credentials for both are required (see below).

## Bento System Overview

![alt text](docs/charts/bento_overview.png "Bento system overview chart")

## Authentication Flow and Guest Mode Details

https://mitlibraries.atlassian.net/wiki/x/CoAeAw

## Loading Hints

Tasks exist to reload hints from supported sources.
Example to reload Aleph hints in a development environment:

```
heroku local:run bin/rails reloadhints:aleph
```

_note_: `reloadhints:aleph` requires ENV `ALEPH_HINT_SOURCE`

To reload custom hints in a development environment:

```
heroku local:run bin/rails reloadhints:custom[https://www.dropbox.com/blah/blah]
```

To reload custom hints in a heroku environment:

```
heroku run bin/rails reloadhints:custom['https://www.dropbox.com/blah/blah'] --app your-appname-staging
```

Depending on your shell, you may need single-quotes around the URL.

This expects to find a world-readable CSV file at the Dropbox location. Instructions for generating that file are in the Google sheet where we gather
custom hint metadata.

## Required Environment Variables

- `ALEPH_API_URI`: endpoint URI for Aleph Realtime Availability checks
- `ALEPH_KEY`: we use a custom API adapter to aleph that restricts via key
  instead of IP address
- `EDS_ARTICLE_FACETS`: facets to apply to create an articles search
  ex: &facetfilter=1,SourceType:Academic+Journals,SourceType:Magazines
- `EDS_BOOK_FACETS`: facets to apply to create a book search
  ex: &facetfilter=1,SourceType:Books,SourceType:eBooks,SourceType:Audiobooks
- `EDS_PASSWORD`: your EDS API password
- `EDS_PLINK_APPEND`: string to append to extracked PLink from EDS
- `EDS_PROFILE`: profile for your EDS API endpoint
- `EDS_PROFILE_URI`: URI for the EDS UI (not API) profile
- `EDS_URL`: the root EDS API URL
- `EDS_USER_ID`: your EDS API user id
- `GOOGLE_API_KEY`: your Google Custom Search API key
- `GOOGLE_CUSTOM_SEARCH_ID`: your Google Custom Search engine ID
- `MAX_AUTHORS`: the maximum number of authors displayed in any record.
  If exceeded, 'et al' will be appended after this number.
- `RECAPTCHA_SITE_KEY`
- `RECAPTCHA_SECRET_KEY`

## Optional Environment Variables

- `ALEPH_HINT_SOURCE`: HTTP GET accessible marcxml source for Hints
- `EDS_TIMEOUT`: value to override the 6 second default for EDS timeout
- `FLIPFLOP_KEY`: set this to enable access to the flipflop dashboard
- `GLOBAL_ALERT`: html message to display as a global header
- `HINT_SOURCES`: Comma-separated Hint source names, in descending order of priority. (If unset, will default to `custom`).
- `JS_EXCEPTION_LOGGER_KEY`: Enables and logs JavaScript errors.
  - Hints will only be displayed to the user if they are in `HINT_SOURCES`.
- `LOG_LIKE_PROD`: uses prod-like logging in development if set
- `LOG_LEVEL`: set log level for development, default is `:debug`
- `RESULTS_PER_BOX`: defaults to 3
- `SENTRY_DSN`: logs exceptions to Sentry

## Developing locally with Docker

A Dockerfile is provided that is intended solely for development work as it is
not optimized for production environments (and in fact doesn't install
production required dependencies so for real don't use it for anything else).

To build the container:

`docker build -t bento .`

To run the application while actively developing:

`docker run -it -p 3000:3000 --mount type=bind,source=$(pwd),target=/bento bento`
should mount your local copy of the code in a way in which
your changes are immediately reflected in the running app.

To run the tests it seems useful to mount your local code into a bash shell to
pick up changes live:

`docker run -it --mount type=bind,source=$(pwd),target=/bento --entrypoint /bin/bash bento`

Once in the containers shell:

`bundle exec rails test` should do the trick

If you just leave those running, you should see changes you make locally
reflected immediately in the running container.

`docker-compose` will load your `.env` file automatically for your config and
we use `/config/environment/test.rb` for test env stuff.
