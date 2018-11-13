require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:comments) }
  it { is_expected.to have_many(:projects) }

  describe 'validations' do
    context '#validates_presence_of' do
      it do
        is_expected.to validate_presence_of(:username)
          .with_message('The field is required.')
      end

      it do
        is_expected.to validate_presence_of(:password)
          .with_message('The field is required.')
      end

      it do
        is_expected.to validate_presence_of(:password_confirmation)
          .with_message('The field is required.')
      end
    end

    context '#validates_length_of' do
      it do
        is_expected.to validate_length_of(:username)
          .is_at_least(3).is_at_most(50)
          .with_short_message('Username is too short. Minimum 3 characters.')
          .with_long_message('Username is too long. Maximum 50 characters.')
      end

      it do
        is_expected.to validate_length_of(:password)
          .is_at_least(8)
          .with_short_message('Password does not meet minimal requirements. ' \
                              'The length should be 8 characters, alphanumeric.')
      end
    end

    context '#validates_uniqueness_of' do
      it do
        is_expected.to validate_uniqueness_of(:username)
          .with_message('This login is already registered. Please, log in.')
          .case_insensitive
      end
    end

    context '#validates_confirmation_of' do
      it do
        is_expected.to validate_confirmation_of(:password)
          .with_message('Password and Confirm password fields doesn’t match.')
      end
    end
  end
end
