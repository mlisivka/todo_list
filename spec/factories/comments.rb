FactoryBot.define do
  factory :comment do
    body { 'Factory comment' }
    association(:user)
    association(:task)
  end
end
