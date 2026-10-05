class Ecoregion < ApplicationRecord
  enum :indicator, {
    ecoregion_asssessment: "ecoregion_asssessment"
  }, prefix: true
  enum :category, {
    cr: "cr",
    en: "en",
    vu: "vu",
    nt: "nt",
    lc: "lc",
    dd: "dd",
    ne: "ne"
  }, prefix: true

  validates_presence_of :indicator, :value, :category
end
