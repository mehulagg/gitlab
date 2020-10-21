# frozen_string_literal: true

module Geo::Syncable
  extend ActiveSupport::Concern

  included do
    scope :failed, -> { where(success: false).where.not(retry_count: nil) }
    scope :missing_on_primary, -> { where(missing_on_primary: true) }
    scope :needs_sync_again, -> { failed.retry_due }
    scope :never_attempted_sync, -> { where(success: false, retry_count: nil) }
    scope :retry_due, -> { where('retry_at is NULL OR retry_at < ?', Time.current) }
    scope :synced, -> { where(success: true) }
  end
end
