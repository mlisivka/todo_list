# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name,
    uniqueness: { message: 'The project with such name does already exist.' }
  validates :name, presence: { message: 'The field is required.' }
end
