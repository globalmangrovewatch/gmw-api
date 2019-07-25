Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :api, defaults: { format: :json } do
    resources :locations do
      resources :mangrove_data
    end

    get 'widget_data/mangrove_coverage', to: 'widget_data#mangrove_coverage'
  end
end
