class ProjectPolicy < ApplicationPolicy
  def index?
    record.all? do |r|
      r.user == user
    end
  end

  def show?
    record.user == user
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  class Scope < Scope
    def resolve
      user.projects
    end
  end
end
