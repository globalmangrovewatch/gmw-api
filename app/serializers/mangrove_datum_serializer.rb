class MangroveDatumSerializer < ActiveModel::Serializer
  attributes :id, :date, :gain_m2, :loss_m2, :net_change_m2, :length_m, :area_m2, :hmax_m, :agb_mgha_1, :hba_m, :con_hotspot_summary_km2

  def con_hotspot_summary_km2
    JSON.parse self.object.con_hotspot_summary_km2 if self.object.con_hotspot_summary_km2
  end

  def agb_hist_mgha_1
    JSON.parse self.object.agb_hist_mgha_1 if self.object.agb_hist_mgha_1
  end

  def hba_hist_m
    JSON.parse self.object.hba_hist_m if self.object.hba_hist_m
  end

  def hmax_hist_m
    JSON.parse self.object.hmax_hist_m if self.object.hmax_hist_m
  end
end
