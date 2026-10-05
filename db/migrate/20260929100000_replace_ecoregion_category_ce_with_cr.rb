class ReplaceEcoregionCategoryCeWithCr < ActiveRecord::Migration[7.0]
  def up
    Ecoregion.where(category: "ce").update_all(category: "cr")
  end

  def down
    Ecoregion.where(category: "cr").update_all(category: "ce")
  end
end
