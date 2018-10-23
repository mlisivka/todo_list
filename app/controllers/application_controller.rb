class ApplicationController < JSONAPI::ResourceController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?

  def respond_with_errors(object)
    render json: {
      errors: ErrorSerializer.serialize(object)
    }, status: :unprocessable_entity
  end

  def json_resource(klass, record, context = nil, options: {})
    JSONAPI::ResourceSerializer.new(klass, options).serialize_to_hash(klass.new(record, context))
  end

  def json_resources(klass, records, context = nil, options: {})
    resources = records.map { |record| klass.new(record, context) }
    JSONAPI::ResourceSerializer.new(klass, options).serialize_to_hash(resources)
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :password, :password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
  end
end
