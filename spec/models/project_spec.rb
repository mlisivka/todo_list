require 'rails_helper'

RSpec.describe Project, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:tasks) }

  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:name)
        .with_message('The field is required.')
    end

    it do
      is_expected.to validate_uniqueness_of(:name)
        .with_message('The project with such name does already exist.')
        .case_insensitive
    end
  end
end
