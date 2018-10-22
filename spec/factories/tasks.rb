FactoryBot.define do
  factory :task do
    sequence(:name) { |n| "Task ##{n}" }
    association(:project)
  end
end
