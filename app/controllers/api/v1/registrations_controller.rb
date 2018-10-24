# frozen_string_literal: true

class Api::V1::RegistrationsController < DeviseTokenAuth::ApplicationController
  include Api::V1::RegistrationsDoc
  before_action :validate_sign_up_params, only: :create

  def create
    build_resource

    if @resource.save
      yield @resource if block_given?

      render json: json_resource(Api::V1::UserResource, @resource),
        status: :created
    else
      clean_up_passwords @resource
      respond_with_errors(@resource)
    end
  end

  def sign_up_params
    params.permit(*params_for_resource(:sign_up))
  end

  protected

  def build_resource
    @resource = resource_class.new(sign_up_params)
    @resource.uid = SecureRandom.uuid

    field = (sign_up_params.keys.map(&:to_sym) &
             resource_class.authentication_keys).first
    value = sign_up_params[field]
    method_name = "#{field}=".to_sym

    if resource_class.case_insensitive_keys.include?(field)
      @resource.send(method_name, value.try(:downcase))
    else
      @resource.send(method_name, value)
    end
  end

  private

  def validate_sign_up_params
    validate_post_data sign_up_params, I18n.t('errors.messages.validate_sign_up_params')
  end

  def validate_post_data which, message
    render_error(:unprocessable_entity, message, status: 'error') if which.empty?
  end
end
