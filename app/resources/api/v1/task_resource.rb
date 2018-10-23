class Api::V1::TaskResource < JSONAPI::Resource
  attributes :name, :due_date, :done, :created_at
  has_many :comments
  has_one :project
end
