# Mangrove Atlas API

## Installation

* PostgreSQL 10+
* Ruby 2.6+

### ENV variables in `.env` file:

```
RAILS_ENV=development
POSTGRES_HOST={postgres_host}
POSTGRES_PORT={port}
HTTP_HOST={host:port}
```
To install run `bundle install`. And start application running `rails s`.

## API documentation

API documentation is available at `/api-docs`.

### Run rswag to generate API documentation

`SWAGGER_DRY_RUN=0 rake rswag:specs:swaggerize`

## Replace snapshot files

On the first run, the `match_snapshot` matcher will always return success and it will store a snapshot file. On the next runs, it will compare the response with the file content.

If you need to replace snapshots, run the specs with:

`REPLACE_SNAPSHOTS=true bundle exec rspec`

If you only need to add, remove or replace data without replacing the whole snapshot:

`CONSERVATIVE_UPDATE_SNAPSHOTS=true bundle exec rspec`

## Run linters

`bin/rails standard`

To fix linter issues

`bin/rails standard:fix`

## Deploy to staging

Merge your code in `develop` branch.

Add heroku site:

```
heroku git:remote -a mangroves-atlas-api
```

And deploy:

```
git push heroku develop:master
```

## Mailer setting

```
MAILER_DEFAULT_HOST={MRTT API base url}
MRTT_UI_BASE_URL={MRTT UI base url}
SMTP_ADDRESS={SMTP address}
SMTP_PORT={SMTP port}
SMTP_USER_NAME={SMTP username}
SMTP_PASSWORD={SMTP password}
```
