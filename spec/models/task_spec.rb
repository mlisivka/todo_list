require 'rails_helper'

RSpec.describe Task, type: :model do
  it { is_expected.to belong_to(:project) }
  it { is_expected.to have_many(:comments) }

  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:name)
        .with_message('The field is required.')
    end

    describe '#due_date_cannot_be_in_the_past' do
      context 'when due date in the past' do
        subject { build(:task, due_date: Time.now - 1.minute) }

        it 'returns an object with error' do
          expect(subject).to be_invalid
          expect(subject.errors[:due_date]).
            to include("The time can't be in the past")
        end

        it 'does not save a record' do
          expect(subject.save).to be_falsey
        end
      end

      context 'when due date in the future' do
        subject { build(:task, due_date: Time.now + 1.minute) }

        it 'marks as valid' do
          expect(subject).to be_valid
        end

        it 'saves a record' do
          expect(subject.save).to be_truthy
        end
      end
    end
  end
end
