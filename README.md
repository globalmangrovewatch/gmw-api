# Mangrove Atlas API

## Installation

* PostgreSQL 10+
* Ruby 2.6+

To install run `bundle install`. And start application running `rails s`.

## API documentation


### Locations

Get all locations, sorted by name and Worldwide at the top.

```
    curl "https://mangrove-atlas-api.herokuapp.com/api/locations"
```

Import locations from CSV

```
    curl -X "POST" "https://mangrove-atlas-api.herokuapp.com/api/locations/import" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@[file_path]"
```

You have to replace `[file_path]`.
If you want to replace all locations, you have to add the param `?reset=true` in the url.


### Mangrove data (data for Widgets)

Get all mangrove data by a location.

```
    curl "https://mangrove-atlas-api.herokuapp.com/api/locations/[location_id | iso]/mangrove_data"
```

Import mangrove data from CSV

```
    curl -X "POST" "https://mangrove-atlas-api.herokuapp.com/api/mangrove_data/import" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@[file_path]"
```

You have to replace `[file_path]`.
If you want to replace all mangrove data, you have to add the param `?reset=true` in the url.


### Generating data for worldwide

To create or update the data for worlwide you can run

```
heroku run rake worldwide:location worldwide:mangrove_datum
```

It iterate over all locations and mangrove data tables to calc and sum the values for Worldwide.


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
