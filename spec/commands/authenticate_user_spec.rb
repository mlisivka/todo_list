require 'rails_helper'

RSpec.describe AuthenticateUser do
  let(:user) { create(:user) }

  describe '#call' do
    context 'when valid credentials' do
      subject(:auth_obj) { described_class.new(user.username, user.password) }

      it 'returns an auth token' do
        token = auth_obj.call.result
        expect(token).to be_present
      end
    end

    context 'when invalid credentials' do
      subject(:invalid_auth_obj) { described_class.new('foo', 'bar') }

      it 'raises AuthenticationError error' do
        expect { invalid_auth_obj.call }
          .to raise_error(
            ExceptionHandler::AuthenticationError,
            /Incorrect login or\(and\) password/
          )
      end
    end
  end
end
