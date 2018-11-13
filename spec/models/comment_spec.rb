require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }

  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:body)
        .with_message('The field is required.')
    end
  end
end
