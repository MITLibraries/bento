[![Depfu](https://badges.depfu.com/badges/4e708126f48dfe5edf3b09b1dbc2854b/overview.svg)](https://depfu.com/github/MITLibraries/bento)
[![Code Climate](https://codeclimate.com/github/MITLibraries/bento/badges/gpa.svg)](https://codeclimate.com/github/MITLibraries/bento)

# MIT Bento

## What is this?

MIT Bento aims to search multiple data sources and return a summary of results
to aid a user towards a successful discovery experience.

It currently searches Primo Search API, TIMDEX API, and Google Custom Search API. Appropriate credentials are required 
for some of these APIs (see below).

## Bento System Overview

![alt text](docs/charts/bento_overview.png "Bento system overview chart")

## Required Environment Variables

- `ALMA_OPENURL`: base URL for Alma openurls found in CDI records.
- `ALMA_SRU`: URL for Alma SRU query on alma.all_for_ui param. This is 
used to determine whether to redirect Bento full record links to Primo 
full records.
- `ASPACE_SEARCH_URI`: the base search URL for the Timdex/ArchiveSpace application
- `EXL_INST_ID`: your Ex Libris institution ID.
- `GOOGLE_API_KEY`: your Google Custom Search API key
- `GOOGLE_CUSTOM_SEARCH_ID`: your Google Custom Search engine ID
- `MAX_AUTHORS`: the maximum number of authors displayed in any record.
  If exceeded, 'et al' will be appended after this number.
- `MIT_PRIMO_URL`: the root URL for MIT Libraries' Primo instance.
- `PRIMO_API_KEY`: the Primo API key.
- `PRIMO_API_URL`: the server URL for the Primo API.
- `PRIMO_ARTICLE_SCOPE`: assigned to the `scope` param of a Primo Search 
API endpoint to limit  the search to CDI (Articles+) results.
- `PRIMO_BOOK_SCOPE`: assigned to the `scope` param of a Primo Search 
API endpoint to limit the search to local/Alma (Books+) results.
- `PRIMO_MAIN_VIEW_TAB` the value of the `tab` param for the Primo UI 
main search view. (This is used for links to Primo searches.)
- `PRIMO_SPLASH_PAGE`: URL for Libraries splash page explaining the transition from EDS to Primo.
- `PRIMO_TAB`: the value of the Primo `tab` param for Bento.
- `PRIMO_VID`: our Primo 'view ID'.
- `SYNDETICS_PRIMO_URL`: the Syndetics API URL for Primo. This is used 
to construct thumbnail URLs.
- `TIMDEX_URL`: The GraphQL endpoint for Timdex/ArchiveSpace

## Optional Environment Variables

- `GLOBAL_ALERT`: html message to display as a global header
- `HINT_SOURCES`: Comma-separated Hint source names, in descending order of priority. (If unset, will default to `custom`).
- `JS_EXCEPTION_LOGGER_KEY`: Enables and logs JavaScript errors.
  - Hints will only be displayed to the user if they are in `HINT_SOURCES`.
- `LOG_LEVEL`: set log level for development, default is `:debug`
- `LOG_LIKE_PROD`: uses prod-like logging in development if set
- `ORIGINS`: sets origins for CORS (currently used only for TACOS API calls).
- `PLATFORM_NAME`: The value set is added to the header after the MIT Libraries logo. The logic and CSS for this comes from our theme gem.
- `PRIMO_TIMEOUT`: value to override the 6 second default for Primo timeout.
- `REQUESTS_PER_PERIOD`: number of requests per time period we allow from a
  single non-MIT IP address. Defaults to 100. Example: "100".
- `REQUEST_PERIOD`: sets time period for number of requests per time period in
  minutes. Defaults to 1 minute. Example: "1". NOTE: for throttles to work in
  development make sure to [enable the dev cache](https://guides.rubyonrails.org/caching_with_rails.html#caching-in-development)
- `RESULTS_PER_BOX`: defaults to 3
- `SENTRY_DSN`: logs exceptions to Sentry
- `SENTRY_ENV`: Sentry environment for the application. Defaults to 'unknown' if unset.
- `TACOS_URL`: The GraphQL endpoint for the [TACOS API](https://github.com/mitlibraries/tacos/). When set, the
application will log search terms to TACOS and return suggested resources detected in search terms.
- `TIMDEX_TIMEOUT`: value to override the 6 second default for TIMDEX timeout.

### NPS Survey Environment Variables (optional)

- `NPS_BLURB`: Text to display before the survey link. Survey link will still display if not provided.
- `NPS_LINK_TEXT`: Survey link text. If not present, survey does not display.
- `NPS_URL`: Survey link URL. If not present, survey does not display.

## Confirming functionality after updating dependencies

This application has good code coverage, so most issues are detected by just running tests normally:

```shell
bin/rails test
```

The following additional manual testing should be performed in the PR build on Heroku.

- Search for a few different terms and confirm results return and are displayed in each of the boxes as appropriate. Not all boxes should return results for all searches, but comparing to production should lead to the same results (although there is a cache in production so if results don't match you might want to first clear the production cache before being overly concerned)
- If the app is integrated with TACOS, the browser console should include a response from that system confirming the search string and source system.
