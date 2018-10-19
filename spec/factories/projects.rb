FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    association(:user)
  end
end
