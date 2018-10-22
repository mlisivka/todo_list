Rails.application.routes.draw do
  apipie
  mount_devise_token_auth_for 'User', at: 'auth'

  namespace :api do
    namespace :v1, path: '' do
      resources :projects do
        resources :tasks do
          resources :comments
        end
      end
    end
  end
end
