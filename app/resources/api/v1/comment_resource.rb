class Api::V1::CommentResource < JSONAPI::Resource
  attributes :body, :image, :created_at
  has_one :user
  has_one :task
end
