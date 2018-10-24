# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviseTokenAuth::SessionsController, type: :request do
  describe '#create' do
    let!(:user) { create(:user) }
    let(:params) do
      { username: user.username,
        password: user.password }
    end

    before do
      post api_v1_user_session_path, params: params
    end

    context 'when username and password are correct' do
      it_behaves_like 'returns http status', :success
    end

    context 'when username is incorrect' do
      let(:params) do
        { username: 'bad_name',
          password: user.password }
      end

      it_behaves_like 'returns http status', :unauthorized

      it 'returns error' do
        expect(errors[0]).to eq 'Incorrect login or(and) password'
      end
    end

    context 'when username is incorrect' do
      let(:params) do
        { username: user.username,
          password: 'bad_pass' }
      end

      it_behaves_like 'returns http status', :unauthorized

      it 'returns error' do
        expect(errors[0]).to eq 'Incorrect login or(and) password'
      end
    end
  end
end
