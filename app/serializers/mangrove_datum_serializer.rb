class MangroveDatumSerializer < ActiveModel::Serializer
  attributes :id,
    :date,
    :gain_m2,
    :loss_m2,
    :net_change_m2,
    :length_m,
    :area_m2,
    :hmax_m,
    :agb_mgha_1,
    :hba_m,
    :agb_hist_mgha_1,
    :con_hotspot_summary_km2,
    :hba_hist_m,
    :hmax_hist_m,
    :agb_tco2e,
    :bgb_tco2e,
    :soc_tco2e,
    :toc_tco2e,
    :toc_hist_tco2eha

  def con_hotspot_summary_km2
    JSON.parse(object.con_hotspot_summary_km2) if object.con_hotspot_summary_km2
  end

  def agb_hist_mgha_1
    JSON.parse(object.agb_hist_mgha_1) if object.agb_hist_mgha_1
  end

  def hmax_hist_m
    JSON.parse(object.hmax_hist_m) if object.hmax_hist_m
  end
end
