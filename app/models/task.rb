class Task < ApplicationRecord
  validates :name, presence: { message: 'The field is required.' }
  validate :due_date_cannot_be_in_the_past

  belongs_to :project

  def due_date_cannot_be_in_the_past
    if due_date.present? && due_date < Date.today
      errors.add(:due_date, "The time can't be in the past")
    end
  end
end
