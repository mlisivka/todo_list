require 'rails_helper'

RSpec.describe CommentPolicy do
  let(:user) { create(:user) }
  let(:visitor) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project) }
  let(:comment) { create(:comment, user: user, task: task) }
  let(:comments) { create_list(:comment, 5, user: user, task: task) }
  let(:visitors_comment) { create(:comment, user: visitor, task: task) }

  subject { described_class }

  permissions :index? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, comments)
      end
    end

    context 'when the user does not own the project' do
      it 'grants access' do
        expect(subject).to permit(visitor, comments)
      end
    end
  end

  permissions :show? do
    context 'when the user own the comment' do
      it 'grants access' do
        expect(subject).to permit(user, comment)
      end
    end

    context 'when the user does not own the comment' do
      context 'when the user own the task' do
        it 'grants access' do
          expect(subject).to permit(user, visitors_comment)
        end
      end

      context 'when the user does not own the task' do
        it 'denies access' do
          expect(subject).not_to permit(visitor, comment)
        end
      end
    end
  end

  permissions :create? do
    context 'when the user has some comments' do
      it 'grants access' do
        expect(subject).to permit(user, build(:comment))
      end
    end

    context 'when the user has no comment' do
      it 'grants access' do
        expect(subject).to permit(visitor, build(:comment))
      end
    end
  end

  permissions :destroy? do
    context 'when the user own the project' do
      it 'grants access' do
        expect(subject).to permit(user, comment)
      end
    end

    context 'when the user does not own the comment' do
      context 'when the user own the task' do
        it 'denies access' do
          expect(subject).not_to permit(user, visitors_comment)
        end
      end

      context 'when the user does not own the task' do
        it 'denies access' do
          expect(subject).not_to permit(visitor, comment)
        end
      end
    end
  end
end
