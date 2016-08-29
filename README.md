[![Build Status](https://travis-ci.org/MITLibraries/bento.svg?branch=master)](https://travis-ci.org/MITLibraries/bento)
[![Coverage Status](https://coveralls.io/repos/github/MITLibraries/bento/badge.svg?branch=master)](https://coveralls.io/github/MITLibraries/bento?branch=master)
[![Dependency Status](https://gemnasium.com/badges/github.com/MITLibraries/bento.svg)](https://gemnasium.com/github.com/MITLibraries/bento)
[![Apache 2 licensed](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://raw.githubusercontent.com/MITLibraries/bento/master/LICENSE.md)

# MIT Bento

## What is this?

MIT Bento aims to search multiple data sources and return a summary of results
to aid a user towards a successful discovery experience.

It currently searches Ebsco Discovery Services API (EDS) and Google Custom
Search API. Appropriate credentials for both are required (see below).

## Required Environment Variables

- `EDS_URL`: the root EDS API URL
- `EDS_USER_ID`: your EDS API user id
- `EDS_PASSWORD`: your EDS API password
- `EDS_NO_ALEPH_PROFILE`: an EDS profile to search for articles
- `EDS_ALEPH_PROFILE`: an EDS profile to search for your local holdings
- `EDS_ALEPH_URI`: the base URI to send a user to your EDS articles profile.
The query will be appended.
- `EDS_NO_ALEPH_URI`: the base URI to send a user to your EDS local holdings
 profile. The query will be appended.
- `GOOGLE_API_KEY`: your Google Custom Search API key
- `GOOGLE_CUSTOM_SEARCH_ID`: your Google Custom Search engine ID
