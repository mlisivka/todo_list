class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :body, presence: { message: 'The field is required.' }
end
