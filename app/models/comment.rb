class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :body, presence: { message: 'The field is required.' }
  validates :image, file_size: {
    less_than: 10.megabytes,
    message: 'An uploaded file is too large. ' \
    'The size shouldn’t exceed %{count} MB.'
  }
  validates :image, file_content_type: {
    allow: ['image/jpg', 'image/png'],
    message: 'Wrong file format. ' \
    'You can upload a *.jpg or *.png formats files only'
  }

  mount_uploader :image, ImageUploader
end
