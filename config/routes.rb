Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :api, defaults: { format: :json } do
    resources :locations
    resources :mangrove_data

    post 'locations/import', to: 'locations#import'
    post 'mangrove_data/import', to: 'mangrove_data#import'

    # Widgets
    get 'widget_data/mangrove_coverage', to: 'widget_data#mangrove_coverage'
  end
end
