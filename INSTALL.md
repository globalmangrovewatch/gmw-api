# Ubuntu

Dependencies

```
sudo apt install build-essential libpq-dev postgres postgres-contrib
```

Ruby required. Install using rbenv or rvm.

Install rails:

```
gem install bundle
bundle install
```

Database configuration:

Set database username `postres` and password `postgres`

and init postgres:

First running:

```
bundle exec rails db:create
```

Restore from dump file:

1. Get the dump file from heroku (staging)

```
pg_dump -O -x -d postgres://username:password@hostname/database > database.sql
```

2. Restore with no user check

```
psql -U postgres -h localhost -d mangrove-atlas-api_development < database.sql
```

Migrate and run:

```
bundle exec rails db:migrate
```

Running:

```
bundle exec rails s
```


## Docker (only first time)

```
docker-compose up --build
```
In a separate terminal, create the database:

```
docker-compose run web rake db:create RAILS_ENV=development
```

Download dump:

```
docker-compose run db pg_dump -O -x -d postgres://username:password@hostname/database > database.sql
```

Restore from dump file:

```
docker-compose run -T db psql postgres://postgres:postgres@db:5432/mangrove-atlas-api_development < database.sql
```

```
docker-compose run web rake db:migrate RAILS_ENV=development
```