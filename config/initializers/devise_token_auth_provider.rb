# frozen_string_literal: true

DeviseTokenAuth::Concerns::ResourceFinder.class_eval do
  def provider
    'username'
  end
end
