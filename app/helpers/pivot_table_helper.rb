module PivotTableHelper
    def grid(data, options = {})
        grid = PivotTable::Grid.new do |g|
            g.source_data = data
            g.column_name = options[:column_name]
            g.row_name = options[:row_name]
            g.value_name = options[:value_name]
            g.field_name = options[:field_name]
        end
        return grid.build.rows
    end
end
