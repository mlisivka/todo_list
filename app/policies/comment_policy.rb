class CommentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owner? || user_own_task?
  end

  def create?
    true
  end

  def destroy?
    owner?
  end

  private

  def owner?
    record.user == user
  end

  def user_own_task?
    user.projects.any? do |project|
      project.tasks.include?(record.task)
    end
  end

  class Scope < Scope
  end
end
