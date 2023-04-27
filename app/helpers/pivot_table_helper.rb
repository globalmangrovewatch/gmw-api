module PivotTableHelper
  def cast_hash(value, cast)
    case cast
    when "integer"
      value.to_i
    when "float"
      value.to_f
    when "boolean"
      value.to_s.downcase == "true"
    when "string"
      value.to_s
    else
      value
    end
  end

  def remap(data, options = {})
    data.map do |datum|
      return [
        datum.orthogonal_headers.zip(datum.data).map { |key, value|
          cast = options.fetch(key, nil)
          [key, cast_hash(value, cast)]
        }.to_h
      ]
    end
    data
  end

  def grid(data, options = {})
    grid = PivotTable::Grid.new do |g|
      g.source_data = data
      g.column_name = options[:column_name]
      g.row_name = options[:row_name]
      g.value_name = options[:value_name]
      g.field_name = options[:field_name]
    end

    remap(grid.build.rows, options[:cast])
  end
end
