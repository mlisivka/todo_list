module Api::V1::RegistrationsDoc
  extend Apipie::DSL::Concern

  def self.superclass
    Api::V1::RegistrationsController
  end

  resource_description do
    resource_id 'Registrations'
    formats [:json]
    api_versions '1'
  end

  def_param_group :user do
    param :user, Hash, only_in: :request, required: true do
      param :username, String, 'The name of user', required: true
      param :password, String, 'Password', required: true
    end

    property :data, Hash do
      property :id, Integer
      property :type, String, 'users'
      property :attributes, Hash do
        param :username, String, 'The name of user'
      end
    end
  end

  api :POST, '/auth/sign_up', 'Register a User'
  param_group :user
  returns code: 201 do
    param_group :user
  end
  def create; end
end
