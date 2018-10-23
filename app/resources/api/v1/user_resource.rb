class Api::V1::UserResource < JSONAPI::Resource
  has_many :projects
  has_many :comments
end
