# API documentation

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