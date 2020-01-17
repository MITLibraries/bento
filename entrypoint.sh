#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /bento/tmp/pids/server.pid

# This will setup a new db if necessary then run migrations
bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
