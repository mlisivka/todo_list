class TaskPolicy < ApplicationPolicy
  def index?
    record.all? do |r|
      user.projects.include?(r.project)
    end
  end

  def show?
    user_own_project?
  end

  def create?
    user_own_project?
  end

  def update?
    user_own_project?
  end

  def destroy?
    user_own_project?
  end

  private

  def user_own_project?
    user.projects.include?(record.project)
  end

  class Scope < Scope
  end
end
