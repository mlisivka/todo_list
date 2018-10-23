class Api::V1::ProjectResource < JSONAPI::Resource
  attributes :name
  has_many :tasks
end
