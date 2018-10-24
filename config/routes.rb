Rails.application.routes.draw do
  apipie
  mount_devise_token_auth_for 'User', at: 'auth'

  namespace :api do
    namespace :v1, path: '' do
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
