require 'rails_helper'

RSpec.describe TaskPolicy do
  let(:user) { create(:user) }
  let(:visitor) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project) }
  let(:tasks) { create_list(:task, 5, project: project) }

  subject { described_class }

  permissions :index? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, tasks)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, tasks)
      end
    end
  end

  permissions :show? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, task)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, task)
      end
    end
  end

  permissions :create? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, build(:task, project: project))
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, build(:task, project: project))
      end
    end
  end

  permissions :update? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, task)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, task)
      end
    end
  end

  permissions :destroy? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, task)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, task)
      end
    end
  end
end
