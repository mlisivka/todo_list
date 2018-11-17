Rails.application.routes.draw do
  apipie

  root 'apipie/apipies#index'

  namespace :api do
    namespace :v1, path: '' do
      post 'auth/sign_in', to: 'sessions#create', as: 'session'
      post 'auth/sign_up', to: 'registrations#create', as: 'registration'

      jsonapi_resources :projects do
        jsonapi_resources :tasks do
          jsonapi_resources :comments
          member do
            post :set_position
          end
        end
      end
    end
  end
end
