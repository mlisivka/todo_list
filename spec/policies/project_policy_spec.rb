require 'rails_helper'

RSpec.describe ProjectPolicy do
  let(:user) { create(:user) }
  let(:visitor) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:projects) { create_list(:project, 5, user: user) }

  subject { described_class }

  permissions :index? do
    context 'when the user own the projects' do
      it 'grants access' do
        expect(subject).to permit(user, projects)
      end
    end

    context 'when the user does not own the projects' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, projects)
      end
    end
  end

  permissions :show? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, project)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, project)
      end
    end
  end

  permissions :create? do
    context 'when the user has some projects' do
      it 'grants access' do
        expect(subject).to permit(user, build(:project))
      end
    end

    context 'when the user has no project' do
      it 'grants access' do
        expect(subject).to permit(visitor, build(:project))
      end
    end
  end

  permissions :update? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, project)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, project)
      end
    end
  end

  permissions :destroy? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, project)
      end
    end

    context 'when the user does not own the project' do
      it 'denies access' do
        expect(subject).not_to permit(visitor, project)
      end
    end
  end
end
