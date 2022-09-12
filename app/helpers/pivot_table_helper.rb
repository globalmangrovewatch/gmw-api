module PivotTableHelper

    def cast_hash(value, cast)
        case cast
        when 'integer'
            return value.to_i 
        when 'float'
            return value.to_f
        when 'boolean'
            return value.to_s.downcase == "true"
        when 'string'
            return value.to_s
        else
          return value
        end
        
    end
    
    def remap(data, options = {})
        data.map do |datum| 
            return [
                datum.orthogonal_headers.zip(datum.data).map { |key, value| 
                    cast = options.fetch(key, nil)
                    [key, cast_hash(value, cast)] }.to_h
                ]
            
        end
        return data
    end

    def grid(data, options = {})
        grid = PivotTable::Grid.new do |g|
            g.source_data = data
            g.column_name = options[:column_name]
            g.row_name = options[:row_name]
            g.value_name = options[:value_name]
            g.field_name = options[:field_name]
        end

        return remap(grid.build.rows,  options[:cast])
    end
end
