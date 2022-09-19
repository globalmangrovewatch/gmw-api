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

## Generating the documentation

```
rails rswag
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
