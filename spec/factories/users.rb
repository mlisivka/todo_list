# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "username#{n}" }
    sequence(:uid) { |n| n }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
