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
    param :username, String, 'The name of user', required: true
    param :password, String, 'Password', required: true
    param :password_confirmation, String, 'Password confirmation', required: true

    property :data, Hash do
      property :id, Integer
      property :type, String, 'users'
      property :attributes, Hash do
        param :username, String, 'The name of user'
      end
    end
  end

  api :POST, '/auth', 'Register a User'
  param_group :user
  returns code: 201 do
    param_group :user
  end
  def create; end
end
