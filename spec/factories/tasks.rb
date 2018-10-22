FactoryBot.define do
  factory :task do
    name { Faker::Lorem.word }
    association(:project)
  end
end
