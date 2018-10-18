# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviseTokenAuth::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#create' do
    let(:params) do
      { username: 'admin',
        password: 'password',
        password_confirmation: 'password' }
    end

    context 'when username is unique' do
      it 'returns a http success' do
        post :create, params: params
        expect(response).to have_http_status(:ok)
      end

      it 'creates a new User' do
        expect { post :create, params: params }.to change(User, :count).by(1)
      end
    end

    context 'when username is not unique' do
      let!(:user) { create(:user, params) }

      it 'returns a http unprocessable_entity' do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'do not creates a new User' do
        expect { post :create, params: params }.not_to change(User, :count)
      end

      it 'returns error' do
        post :create, params: params
        expect(errors['username'][0])
          .to eq 'This login is already registered. Please, log in.'
      end
    end

    context 'when a record is invalid' do
      it 'returns error if username is too long' do
        post :create, params: { username: Faker::Lorem.characters(51),
                                password: 'password',
                                password_confirmation: 'password' }
        expect(errors['username'][0])
          .to eq 'Username is too long. Maximum 50 characters.'
      end

      it 'returns error if username is too short' do
        post :create, params: { username: 'us',
                                password: 'password',
                                password_confirmation: 'password' }
        expect(errors['username'][0])
          .to eq 'Username is too short. Minimum 3 characters.'
      end

      it 'returns error if password is too short' do
        post :create, params: { username: 'admin',
                                password: 'pass',
                                password_confirmation: 'pass' }
        expect(errors['password'][0])
          .to eq 'Password does not meet minimal requirements. ' \
            'The length should be 8 characters, alphanumeric.'
      end

      it 'returns error if passwords does not match' do
        post :create, params: { username: 'admin',
                                password: 'password',
                                password_confirmation: 'pass' }
        expect(errors['password_confirmation'][0])
          .to eq 'Password and Confirm password fields doesn’t match.'
      end

      it 'returns error if username is empty' do
        post :create, params: { username: '',
                                password: 'password',
                                password_confirmation: 'password' }
        expect(errors['username'][0]).to eq 'The field is required.'
      end

      it 'returns error if password is empty' do
        post :create, params: { username: 'admin',
                                password: '',
                                password_confirmation: 'password' }
        expect(errors['password'][0]).to eq 'The field is required.'
      end

      it 'returns error if password_confirmation is empty' do
        post :create, params: { username: 'admin',
                                password: 'password',
                                password_confirmation: '' }
        expect(errors['password_confirmation'][0])
          .to eq 'The field is required.'
      end
    end
  end
end
