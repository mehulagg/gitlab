# frozen_string_literal: true

class AlertManagement::HttpIntegration < ApplicationRecord
  belongs_to :project, inverse_of: :alert_http_integrations

  attr_encrypted :token,
    mode: :per_attribute_iv,
    key: Settings.attr_encrypted_db_key_base_truncated,
    algorithm: 'aes-256-gcm'

  validates :project, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :token, presence: true, if: :active?
  validates :name, presence: true, if: :endpoint_identifier
  validates :endpoint_identifier, presence: true, if: :name
  validates :endpoint_identifier, uniqueness: { scope: [:project_id, :active] }

  before_validation :prevent_token_assignment
  before_validation :ensure_token, if: :active?

  private

  def prevent_token_assignment
    self.token = token_was if token.present? && token_changed?
  end

  def ensure_token
    self.token = generate_token if token.blank?
  end

  def generate_token
    SecureRandom.hex
  end
end
