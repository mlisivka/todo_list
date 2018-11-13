# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: { message: 'The field is required.' },
    uniqueness: { message: 'The project with such name does already exist.',
    case_sensitive: false }
end
