# frozen_string_literal: true

class Project < ApplicationRecord
  validates :name,
    uniqueness: { message: 'The project with such name does already exist.' }
  validates :name, presence: { message: 'The field is required.' }

  belongs_to :user
end
