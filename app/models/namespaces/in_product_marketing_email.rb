# frozen_string_literal: true

module Namespaces
  class InProductMarketingEmail < ApplicationRecord
    include BulkInsertSafe

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

    enum track: {
      create: 0,
      verify: 1,
      trial: 2,
      team: 3
    }, _suffix: true

    scope :without_track_or_series, -> (track, series) do
      where.not(track: track).or(where.not(series: series))
    end
  end
end
