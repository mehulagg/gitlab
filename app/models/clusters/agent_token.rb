# frozen_string_literal: true

module Clusters
  class AgentToken < ApplicationRecord
    include RedisCacheable
    include TokenAuthenticatable

    add_authentication_token_field :token, encrypted: :required, token_generator: -> { Devise.friendly_token(50) }

    self.table_name = 'cluster_agent_tokens'

    belongs_to :agent, class_name: 'Clusters::Agent', optional: false
    belongs_to :created_by_user, class_name: 'User', optional: true

    before_save :ensure_token

    validates :description, length: { maximum: 1024 }
    validates :name, presence: true, length: { maximum: 255 }, on: :create

    # The `UPDATE_USED_COLUMN_EVERY` defines how often the Runner DB entry can be updated
    UPDATE_USED_COLUMN_EVERY = (40.minutes..55.minutes).freeze

    def heartbeat
      values = { last_used_at: Time.current }

      cache_attributes(values)

      # We save data without validation, it will always change due to `last_used_at`
      self.update_columns(values) if persist_cached_data?
    end

    private

    def persist_cached_data?
      # Use a random threshold to prevent beating DB updates.
      last_used_at_at_max_age = Random.rand(UPDATE_USED_COLUMN_EVERY)

      real_last_used_at = read_attribute(:last_used_at)
      real_last_used_at.nil? ||
        (Time.current - real_last_used_at) >= last_used_at_at_max_age
    end
  end
end
