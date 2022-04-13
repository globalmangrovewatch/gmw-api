ActiveAdmin.register MangroveDatum do

  active_admin_import

  permit_params :date, :gain_m2, :loss_m2, :length_m, :area_m2, :hmax_m, :agb_mgha_1,
    :hba_m, :location_id, :con_hotspot_summary_km2, :net_change_m2, :agb_hist_mgha_1,
    :hba_hist_m, :hmax_hist_m, :total_carbon, :agb_tco2e, :bgb_tco2e, :soc_tco2e,
    :toc_tco2e, :toc_hist_tco2eha

  index do
    selectable_column
    id_column
    column :date
    column :location
    column :created_at
    actions
  end

  form do |f|
    f.inputs 'Details'

    actions
  end
  
end
