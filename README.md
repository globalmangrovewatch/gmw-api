# Mangrove Atlas API

## Installation

* PostgreSQL 10+
* Ruby 2.6+

To install run `bundle install`. And start application running `rails s`.

## API documentation


### Locations

Get all locations

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

### Mangrove data (raw data for widgets)

Get all mangrove data

```
    curl "https://mangrove-atlas-api.herokuapp.com/api/mangrove_data"
```

Import mangrove data from CSV

```
    curl -X "POST" "https://mangrove-atlas-api.herokuapp.com/api/mangrove_data/import" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@[file_path]"
```

You have to replace `[file_path]`.
If you want to replace all locations, you have to add the param `?reset=true` in the url.

### Widgets

Mangrove coverage

```
    curl "https://mangrove-atlas-api.herokuapp.com/api/widget_data/mangrove_coverage"
```

You can filter by country `country=[iso]` or by `location_id=[id]`.

