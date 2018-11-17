require 'rails_helper'

RSpec.describe AuthorizeApiRequest do
  let(:user) { create(:user) }

  describe '#call' do
    context 'when valid request' do
      let(:header) { { 'Authorization' => token_generator(user.id) } }
      subject(:request_obj) { described_class.new(header) }

      it 'returns user object' do
        result = request_obj.call.result
        expect(result).to eq(user)
      end
    end

    context 'when invalid request' do
      context 'when missing token' do
        subject(:invalid_request_obj) { described_class.new({}) }

        it 'raises a MissingToken error' do
          expect { invalid_request_obj.call }
            .to raise_error(ExceptionHandler::MissingToken, 'Missing token')
        end
      end

      context 'when user not found' do
        let(:header) { { 'Authorization' => token_generator(5) } }
        subject(:invalid_request_obj) { described_class.new(header) }

        it 'raises an InvalidToken error' do
          expect { invalid_request_obj.call }
            .to raise_error(ExceptionHandler::InvalidToken, /Invalid token/)
        end
      end

      context 'when token is expired' do
        let(:header) { { 'Authorization' => expired_token_generator(user.id) } }
        subject(:invalid_request_obj) { described_class.new(header) }

        it 'raises ExpiredSignature error' do
          expect { invalid_request_obj.call }
            .to raise_error(
              ExceptionHandler::ExpiredSignature,
              /Signature has expired/
            )
        end
      end

      context 'when invalid token' do
        let(:header) { { 'Authorization' => 'foobar' } }
        subject(:invalid_request_obj) { described_class.new(header) }

        it 'raises DecodeError error' do
          expect { invalid_request_obj.call }
            .to raise_error(
              ExceptionHandler::DecodeError,
              /Not enough or too many segments/
            )
        end
      end
    end
  end
end
