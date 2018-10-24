class Api::V1::UserResource < JSONAPI::Resource
  attributes :username
  has_many :projects
  has_many :comments
end
