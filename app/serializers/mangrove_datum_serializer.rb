class MangroveDatumSerializer < ActiveModel::Serializer
  attributes :id, :date, :gain_m2, :loss_m2, :length_m, :area_m2, :hmax_m, :agb_mgha_1, :hba_m, :con_hotspot_summary_km2

  def con_hotspot_summary_km2
    JSON.parse self.object.con_hotspot_summary_km2 if self.object.con_hotspot_summary_km2
  end
end