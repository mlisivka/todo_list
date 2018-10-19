Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  namespace :api do
    namespace :v1, path: '' do
      resource :projects, only: %i[create update destroy]
    end
  end
end
