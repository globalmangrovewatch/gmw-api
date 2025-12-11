Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Handle CORS preflight requests
  match '*path', to: 'application#cors_preflight', via: :options

  # Token auth
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    confirmations: "users/confirmations",
    passwords: "users/passwords"
  }
  get "/users/current_user", to: "users/current_user#show"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :api do
    namespace :v2, defaults: {format: :json} do
      resources :locations
      resources :species, only: [:index]

      get "/widgets/protected-areas", to: "widgets#protected_areas"
      post "/widgets/protected-areas/import", to: "widgets#protected_areas_import"

      get "/widgets/biodiversity", to: "widgets#biodiversity"
      get "/widgets/restoration-potential", to: "widgets#restoration_potential"
      get "/widgets/degradation-and-loss", to: "widgets#degradation_and_loss"
      get "/widgets/blue-carbon-investment", to: "widgets#blue_carbon_investment"
      get "/widgets/international_status", to: "widgets#international_status"
      get "/widgets/ecosystem_services", to: "widgets#ecosystem_service"
      get "/widgets/habitat_extent", to: "widgets#habitat_extent"
      get "/widgets/net_change", to: "widgets#net_change"
      get "/widgets/aboveground_biomass", to: "widgets#aboveground_biomass"
      get "/widgets/tree_height", to: "widgets#tree_height"
      get "/widgets/blue_carbon", to: "widgets#blue_carbon"
      get "/widgets/mitigation_potentials", to: "widgets#mitigation_potencials"
      get "/widgets/country_ranking", to: "widgets#country_ranking"
      get "/widgets/drivers_of_change", to: "widgets#drivers_of_change"
      get "/widgets/sites_filters", to: "widgets#sites_filters"
      get "/widgets/sites", to: "widgets#sites"
      get "/widgets/flood_protection", to: "widgets#flood_protection"
      get "/widgets/national_dashboard", to: "widgets#national_dashboard"
      get "/widgets/fisheries", to: "widgets#fisheries"
      get "/widgets/ecoregions", to: "widgets#ecoregions"
      get "/widgets/fishery_mitigation_potentials", to: "widgets#fishery_mitigation_potentials"

      ## Geometry file conversion
      post "/spatial_file/converter", to: "file_converter#convert"

      # MRTT
      resources :sites, only: [:index, :show, :create, :update, :destroy]
      resources :landscapes, only: [:index, :show, :create, :update, :destroy]
      resources :organizations, only: [:index, :show, :create, :update, :destroy]

      get "/sites/:site_id/registration_intervention_answers", to: "registration_intervention_answers#index"
      put "/sites/:site_id/registration_intervention_answers", to: "registration_intervention_answers#update"
      patch "/sites/:site_id/registration_intervention_answers", to: "registration_intervention_answers#partial_update"

      post "/sites/:site_id/monitoring_answers", to: "monitoring_answers#create"
      get "/sites/:site_id/monitoring_answers", to: "monitoring_answers#index"
      get "/sites/:site_id/monitoring_answers/:uuid", to: "monitoring_answers#index_per_form"
      put "/sites/:site_id/monitoring_answers/:uuid", to: "monitoring_answers#update_per_form"
      delete "/sites/:site_id/monitoring_answers/:uuid", to: "monitoring_answers#delete"

      get "/organizations/:organization_id/users", to: "organizations#get_users"
      get "/organizations/:organization_id/users/:email", to: "organizations#get_user", constraints: {email: /[^\/]+/}
      post "/organizations/:organization_id/users", to: "organizations#add_user"
      patch "/organizations/:organization_id/users/:email", to: "organizations#update_user", constraints: {email: /[^\/]+/}
      delete "/organizations/:organization_id/users/:email", to: "organizations#remove_user", constraints: {email: /[^\/]+/}

      get "/dashboard/sites", to: "dashboard#sites"

      get "/report/answers", to: "report#answers"
      get "/report/answers/:site_id", to: "report#answers_by_site"
      get "/report/answers_as_pdf/:site_id", to: "pdf_report#export_pdf_single_site", as: "single_site"
      get "/report/answers_as_xlsx", to: "report#answers_as_xlsx"
    end

    namespace :v3, defaults: {format: :json} do
      resources :locations
      resources :species, only: [:index]

      get "/widgets/protected-areas", to: "widgets#protected_areas"
      post "/widgets/protected-areas/import", to: "widgets#protected_areas_import"

      get "/widgets/biodiversity", to: "widgets#biodiversity"
      get "/widgets/restoration-potential", to: "widgets#restoration_potential"
      get "/widgets/degradation-and-loss", to: "widgets#degradation_and_loss"
      get "/widgets/blue-carbon-investment", to: "widgets#blue_carbon_investment"
      get "/widgets/international_status", to: "widgets#international_status"
      get "/widgets/ecosystem_services", to: "widgets#ecosystem_service"
      get "/widgets/habitat_extent", to: "widgets#habitat_extent"
      get "/widgets/net_change", to: "widgets#net_change"
      get "/widgets/aboveground_biomass", to: "widgets#aboveground_biomass"
      get "/widgets/tree_height", to: "widgets#tree_height"
      get "/widgets/blue_carbon", to: "widgets#blue_carbon"
      get "/widgets/mitigation_potentials", to: "widgets#mitigation_potencials"
      get "/widgets/country_ranking", to: "widgets#country_ranking"
      get "/widgets/drivers_of_change", to: "widgets#drivers_of_change"
      get "/widgets/sites_filters", to: "widgets#sites_filters"
      get "/widgets/sites", to: "widgets#sites"
      get "/widgets/flood_protection", to: "widgets#flood_protection"
      get "/widgets/national_dashboard", to: "widgets#national_dashboard"
      get "/widgets/fisheries", to: "widgets#fisheries"
      get "/widgets/ecoregions", to: "widgets#ecoregions"
      get "/widgets/fishery_mitigation_potentials", to: "widgets#fishery_mitigation_potentials"

      ## Geometry file conversion
      post "/spatial_file/converter", to: "file_converter#convert"

      # MRTT
      resources :sites, only: [:index, :show, :create, :update, :destroy]
      resources :landscapes, only: [:index, :show, :create, :update, :destroy]
      resources :organizations, only: [:index, :show, :create, :update, :destroy]

      get "/sites/:site_id/registration_intervention_answers", to: "registration_intervention_answers#index"
      put "/sites/:site_id/registration_intervention_answers", to: "registration_intervention_answers#update"
      patch "/sites/:site_id/registration_intervention_answers", to: "registration_intervention_answers#partial_update"

      post "/sites/:site_id/monitoring_answers", to: "monitoring_answers#create"
      get "/sites/:site_id/monitoring_answers", to: "monitoring_answers#index"
      get "/sites/:site_id/monitoring_answers/:uuid", to: "monitoring_answers#index_per_form"
      put "/sites/:site_id/monitoring_answers/:uuid", to: "monitoring_answers#update_per_form"
      delete "/sites/:site_id/monitoring_answers/:uuid", to: "monitoring_answers#delete"

      get "/organizations/:organization_id/users", to: "organizations#get_users"
      get "/organizations/:organization_id/users/:email", to: "organizations#get_user", constraints: {email: /[^\/]+/}
      post "/organizations/:organization_id/users", to: "organizations#add_user"
      patch "/organizations/:organization_id/users/:email", to: "organizations#update_user", constraints: {email: /[^\/]+/}
      delete "/organizations/:organization_id/users/:email", to: "organizations#remove_user", constraints: {email: /[^\/]+/}

      get "/dashboard/sites", to: "dashboard#sites"

      get "/report/answers", to: "report#answers"
      get "/report/answers/:site_id", to: "report#answers_by_site"
      get "/report/answers_as_pdf/:site_id", to: "pdf_report#export_pdf_single_site", as: "v3_single_site"
      get "/report/answers_as_xlsx", to: "report#answers_as_xlsx"
    end
  end
end
