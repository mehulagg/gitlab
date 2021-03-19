# frozen_string_literal: true

module EE
  module GpgKey
    extend ActiveSupport::Concern

    prepended do
      scope :preload_users, -> { preload(:user) }
      scope :for_user, -> (user) { where(user: user) }
    end
  end
end
