Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :api, defaults: { format: :json } do
    resources :locations do
      resources :mangrove_data do
        # post 'import', to: 'mangrove_data#import'
      end

    end

    post 'locations/import', to: 'locations#import'

    # Widgets
    get 'widget_data/mangrove_coverage', to: 'widget_data#mangrove_coverage'
  end
end
