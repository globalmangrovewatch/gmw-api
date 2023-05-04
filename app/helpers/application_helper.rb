module ApplicationHelper
  def cum_sum(array, init, key)
    array.map do |item|
      init += item[key]
      item.cum_sum = init
    end

    array
  end
end
