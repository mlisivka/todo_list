module ExceptionHandler
  extend ActiveSupport::Concern

  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end
  class ExpiredSignature < StandardError; end
  class DecodeError < StandardError; end

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ExceptionHandler::MissingToken, with: :unauthorized_request
    rescue_from ExceptionHandler::InvalidToken, with: :four_twenty_two
    rescue_from ExceptionHandler::ExpiredSignature, with: :four_twenty_two
    rescue_from ExceptionHandler::DecodeError, with: :four_twenty_two

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
  end

  private

  def respond_with_errors(object, status = 422)
    render json: {
      errors: ErrorSerializer.serialize(object, status)
    }, status: status
  end

  def four_twenty_two(e)
    respond_with_errors(e)
  end

  def unauthorized_request(e)
    respond_with_errors(e, 401)
  end

  def record_not_found(e)
    respond_with_errors(e, 404)
  end
end
