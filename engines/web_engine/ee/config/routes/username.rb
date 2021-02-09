# frozen_string_literal: true

scope :username do
  get 'suggestion', to: 'usernames#suggest'
end
