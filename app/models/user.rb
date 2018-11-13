# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable
  include DeviseTokenAuth::Concerns::User

  has_many :projects, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :username, :password, :password_confirmation,
    presence: { message: 'The field is required.' }
  validates :username,
    length: { maximum: 50, minimum: 3,
              too_long: "Username is too long. Maximum %{count} characters.",
              too_short: "Username is too short. Minimum %{count} characters."},
    uniqueness: { message: 'This login is already registered. Please, log in.',
                  case_sensitive: false }
  validates :password,
    length: { minimum: 8,
              too_short: "Password does not meet minimal requirements. " \
                "The length should be %{count} characters, alphanumeric."}
  validates :password, confirmation: { message: 'Password and Confirm ' \
                                       'password fields doesn’t match.' }
end
