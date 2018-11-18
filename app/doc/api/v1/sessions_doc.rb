module Api::V1::SessionsDoc
  extend Apipie::DSL::Concern

  def self.superclass
    Api::V1::SessionsController
  end

  resource_description do
    resource_id 'Sessions'
    formats [:json]
    api_versions '1'
  end

  def_param_group :user do
    param :username, String, 'The name of user', required: true
    param :password, String, 'Password', required: true

  end

  api :POST, '/auth/sign_in', 'Sign in a User'
  header 'Authentication', 'Auth header', required: true
  param_group :user
  returns code: 200 do
    property 'Authentication', String,
             'Auth header. Set it in you Authentication header'
  end
  def create; end
end
