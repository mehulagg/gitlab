# frozen_string_literal: true

class WebHook < ApplicationRecord
  include Sortable

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

  # rubocop: disable CodeReuse/ServiceClass
  def execute(data, hook_name)
    WebHookService.new(self, data, hook_name).execute
  end
  # rubocop: enable CodeReuse/ServiceClass

  # rubocop: disable CodeReuse/ServiceClass
  def async_execute(data, hook_name)
    WebHookService.new(self, data, hook_name).async_execute
  end
  # rubocop: enable CodeReuse/ServiceClass

  # Allow urls pointing localhost and the local network
  def allow_local_requests?
    Gitlab::CurrentSettings.allow_local_requests_from_web_hooks_and_services?
  end

  def log_execution(trigger:, headers:, request_data:, response_headers: {}, response_body: '', response_status:, execution_duration:, error_message: nil)
    self.web_hook_logs.create(
      trigger: trigger,
      url: url,
      execution_duration: execution_duration,
      request_headers: headers,
      request_data: request_data,
      response_headers: response_headers,
      response_body: safe_response_body(response_body),
      response_status: response_status,
      internal_error_message: error_message
    )
  end

  private

  # Todo: this could be a before_save hook in WebHookLog
  def safe_response_body(body)
    body.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end
