# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :request do
  describe '#create' do
    let(:params) do
      { username: 'admin',
        password: 'password',
        password_confirmation: 'password' }
    end

    context 'when username is unique' do
      it 'returns a http success' do
        post api_v1_user_registration_path, params: params
        expect(response).to have_http_status(:created)
      end

      it 'creates a new User' do
        expect { post api_v1_user_registration_path, params: params }
          .to change(User, :count).by(1)
      end
    end

    context 'when username is not unique' do
      let!(:user) { create(:user, params) }

      it 'returns a http unprocessable_entity' do
        post api_v1_user_registration_path, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'do not creates a new User' do
        expect { post api_v1_user_registration_path, params: params }
          .not_to change(User, :count)
      end

      it 'returns error' do
        post api_v1_user_registration_path, params: params
        expect(errors[0]['detail'])
          .to eq 'This login is already registered. Please, log in.'
      end
    end

    context 'when a record is invalid' do
      it 'returns error if username is too long' do
        post api_v1_user_registration_path, params: {
          username: Faker::Lorem.characters(51),
          password: 'password',
          password_confirmation: 'password'
        }
        expect(errors[0]['detail'])
          .to eq 'Username is too long. Maximum 50 characters.'
      end

      it 'returns error if username is too short' do
        post api_v1_user_registration_path, params: { username: 'us',
                                                      password: 'password',
                                                      password_confirmation: 'password' }
        expect(errors[0]['detail'])
          .to eq 'Username is too short. Minimum 3 characters.'
      end

      it 'returns error if password is too short' do
        post api_v1_user_registration_path, params: { username: 'admin',
                                                      password: 'pass',
                                                      password_confirmation: 'pass' }
        expect(errors[0]['detail'])
          .to eq 'Password does not meet minimal requirements. ' \
            'The length should be 8 characters, alphanumeric.'
      end

      it 'returns error if passwords does not match' do
        post api_v1_user_registration_path, params: { username: 'admin',
                                                      password: 'password',
                                                      password_confirmation: 'pass' }
        expect(errors[0]['detail'])
          .to eq 'Password and Confirm password fields doesn’t match.'
      end

      it 'returns error if username is empty' do
        post api_v1_user_registration_path, params: { username: '',
                                                      password: 'password',
                                                      password_confirmation: 'password' }
        expect(errors[0]['detail']).to eq 'The field is required.'
      end

      it 'returns error if password is empty' do
        post api_v1_user_registration_path, params: { username: 'admin',
                                                      password: '',
                                                      password_confirmation: 'password' }
        expect(errors[0]['detail']).to eq 'The field is required.'
      end

      it 'returns error if password_confirmation is empty' do
        post api_v1_user_registration_path, params: { username: 'admin',
                                                      password: 'password',
                                                      password_confirmation: '' }
        expect(errors[0]['detail'])
          .to eq 'The field is required.'
      end
    end
  end
end
