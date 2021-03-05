# frozen_string_literal: true

module Namespaces
  class InProductMarketingEmail < ApplicationRecord
    belongs_to :user
    belongs_to :namespace

    validates :user, presence: true
    validates :namespace, presence: true
    validates :track, presence: true
    validates :series, presence: true
    validates :user_id, uniqueness: {
      scope: [:track, :series],
      message: 'has already been sent'
    }

    enum tracks: {
      create_track: 0,
      verify_track: 1,
      trial_track: 2,
      team_track: 3
    }
  end
end
