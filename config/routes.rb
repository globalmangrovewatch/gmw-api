Rails.application.routes.draw do
  # Token auth
  devise_for :users,
  controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',

  }
  get '/users/current_user', to: 'users/current_user#show'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :api do
    namespace :v1, defaults: { format: :json } do
      get '/locations/worldwide', to: 'locations#worldwide'
      get '/locations/worldwide/mangrove_data', to: 'mangrove_data#worldwide'
  
      resources :locations, except: [:worldwide] do
        resources :mangrove_data, except: [:worldwide]
      end
  
      # Import CSV
      post 'locations/import', to: 'locations#import'
      post 'locations/import_geojson', to: 'locations#import_geojson'
      post 'mangrove_data/import', to: 'mangrove_data#import'
      post 'mangrove_data/import_geojson', to: 'mangrove_data#import_geojson'
    end

    namespace :v2, defaults: { format: :json } do
      resources :locations
      resources :species, only: [:index]

      get '/widgets/protected-areas', to: 'widgets#protected_areas'
      post '/widgets/protected-areas/import', to: 'widgets#protected_areas_import'
      
      get '/widgets/biodiversity', to: 'widgets#biodiversity'
      get '/widgets/restoration-potential', to: 'widgets#restoration_potential'
      get '/widgets/degradation-and-loss', to: 'widgets#degradation_and_loss'
      get '/widgets/blue-carbon-investment', to: 'widgets#blue_carbon_investment'
      get '/widgets/international_status', to: 'widgets#international_status'
      get '/widgets/ecosystem_services', to: 'widgets#ecosystem_service'

      # MRTT
      resources :sites, only: [:index, :show, :create, :update, :destroy]
      resources :landscapes, only: [:index, :show, :create, :update, :destroy]
      resources :organizations, only: [:index, :show, :create, :update, :destroy]
      get '/sites/:site_id/registration_answers', to: 'registration_answers#index'
      put '/sites/:site_id/registration_answers', to: 'registration_answers#update'
      patch '/sites/:site_id/registration_answers', to: 'registration_answers#partial_update'
      get '/sites/:site_id/intervention_answers', to: 'intervention_answers#index'
      put '/sites/:site_id/intervention_answers', to: 'intervention_answers#update'
      patch '/sites/:site_id/intervention_answers', to: 'intervention_answers#partial_update'

    end
  end
end


