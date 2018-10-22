class Task < ApplicationRecord
  validates :name, presence: { message: 'The field is required.' }

  belongs_to :project
end
