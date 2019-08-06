Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :api, defaults: { format: :json } do
    resources :locations do
      resources :mangrove_data

      get '/worldwide/mangrove_data', to: 'mangrove_data#worldwide'
    end

    # Import CSV
    post 'locations/import', to: 'locations#import'
    post 'mangrove_data/import', to: 'mangrove_data#import'
  end
end
