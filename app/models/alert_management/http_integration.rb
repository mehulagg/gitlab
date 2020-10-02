# frozen_string_literal: true

module AlertManagement
  class HttpIntegration < ApplicationRecord
    include Gitlab::Routing.url_helpers

    LEGACY_IDENTIFIER = 'legacy'
    DEFAULT_NAME = 'integration-name'

    belongs_to :project, inverse_of: :alert_management_http_integrations

    attr_encrypted :token,
      mode: :per_attribute_iv,
      key: Settings.attr_encrypted_db_key_base_truncated,
      algorithm: 'aes-256-gcm'

    validates :project, presence: true
    validates :active, inclusion: { in: [true, false] }

    validates :token, presence: true, format: { with: /\A\h{32}\z/ }
    validates :name, presence: true, length: { maximum: 255 }
    validates :endpoint_identifier, presence: true, length: { maximum: 255 }, format: { with: /\A[A-Za-z0-9]+\z/ }
    validates :endpoint_identifier, uniqueness: { scope: [:project_id, :active] }, if: :active?

    before_validation :prevent_token_assignment
    before_validation :prevent_endpoint_identifier_assignment
    before_validation :ensure_token

    scope :for_endpoint_identifier, -> (endpoint_identifier) { where(endpoint_identifier: endpoint_identifier) }
    scope :active, -> { where(active: true) }

    def initialize(args = {})
      super(
        endpoint_identifier: SecureRandom.hex(8),
        **args
      )
    end

    def url
      return project_alerts_notify_url(project, format: :json) if legacy?

      project_alert_http_integration_url(project, name_for_url, endpoint_identifier, format: :json)
    end

    def legacy?
      endpoint_identifier == LEGACY_IDENTIFIER
    end

    private

    def prevent_token_assignment
      if token.present? && token_changed?
        self.token = nil
        self.encrypted_token = encrypted_token_was
        self.encrypted_token_iv = encrypted_token_iv_was
      end
    end

    def ensure_token
      self.token = SecureRandom.hex if token.blank?
    end

    def prevent_endpoint_identifier_assignment
      if endpoint_identifier_changed? && endpoint_identifier_was.present?
        self.endpoint_identifier = endpoint_identifier_was
      end
    end

    def name_for_url
      name&.parameterize || DEFAULT_NAME
    end
  end
end
