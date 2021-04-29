# frozen_string_literal: true

class WebHook < ApplicationRecord
  include Sortable

  FAILURE_THRESHOLD = 3 # three strikes

  attr_encrypted :token,
                 mode:      :per_attribute_iv,
                 algorithm: 'aes-256-gcm',
                 key:       Settings.attr_encrypted_db_key_base_32

  attr_encrypted :url,
                 mode:      :per_attribute_iv,
                 algorithm: 'aes-256-gcm',
                 key:       Settings.attr_encrypted_db_key_base_32

  has_many :web_hook_logs

  validates :url, presence: true
  validates :url, public_url: true, unless: ->(hook) { hook.is_a?(SystemHook) }

  validates :token, format: { without: /\n/ }
  validates :push_events_branch_filter, branch_filter: true

  scope :executable, -> { where('recent_failures <= ? AND (disabled_until IS NULL OR disabled_until < ?)', FAILURE_THRESHOLD, Time.current) }

  def executable?
    recent_failures <= FAILURE_THRESHOLD && (disabled_until.nil? || disabled_until < Time.current)
  end

  # rubocop: disable CodeReuse/ServiceClass
  def execute(data, hook_name)
    WebHookService.new(self, data, hook_name).execute if executable?
  end
  # rubocop: enable CodeReuse/ServiceClass

  # rubocop: disable CodeReuse/ServiceClass
  def async_execute(data, hook_name)
    WebHookService.new(self, data, hook_name).async_execute if executable?
  end
  # rubocop: enable CodeReuse/ServiceClass

  # Allow urls pointing localhost and the local network
  def allow_local_requests?
    Gitlab::CurrentSettings.allow_local_requests_from_web_hooks_and_services?
  end

  def help_path
    'user/project/integrations/webhooks'
  end
end
