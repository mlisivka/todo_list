Rails.application.routes.draw do
  apipie

  root 'apipie/apipies#index'

  namespace :api do
    namespace :v1, path: '' do
      mount_devise_token_auth_for 'User', at: 'auth',
        controllers: {
          registrations: 'api/v1/registrations'
        }

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
