class ApplicationController < JSONAPI::ResourceController
  protect_from_forgery with: :exception, prepend: true
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request
  attr_reader :current_user

  include ExceptionHandler

  def json_resource(klass, record, context = nil, options: {})
    JSONAPI::ResourceSerializer.new(klass, options)
      .serialize_to_hash(klass.new(record, context))
  end

  def json_resources(klass, records, context = nil, options: {})
    resources = records.map { |record| klass.new(record, context) }
    JSONAPI::ResourceSerializer.new(klass, options).serialize_to_hash(resources)
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
