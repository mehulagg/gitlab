# frozen_string_literal: true

class DastSiteProfile < ApplicationRecord
  belongs_to :project
  belongs_to :dast_site

  validates :name, length: { maximum: 255 }, uniqueness: { scope: :project_id }
  validates :project_id, :dast_site_id, presence: true
  validates :secret_key_iv, uniqueness: true
  validate :dast_site_project_id_fk

  scope :with_dast_site_and_validation, -> { includes(dast_site: :dast_site_validation) }

  before_update :set_secret_key_and_iv
  after_destroy :cleanup_dast_site

  delegate :dast_site_validation, to: :dast_site, allow_nil: true

  attr_encrypted :secret_key,
                 mode: :per_attribute_iv_and_salt,
                 insecure_mode: true,
                 key: Settings.attr_encrypted_db_key_base,
                 algorithm: 'aes-256-gcm'

  def status
    return DastSiteValidation::NONE_STATE unless dast_site_validation

    dast_site_validation.state
  end

  private

  def cleanup_dast_site
    dast_site.destroy if dast_site.dast_site_profiles.empty?
  end

  def dast_site_project_id_fk
    unless project_id == dast_site&.project_id
      errors.add(:project_id, 'does not match dast_site.project')
    end
  end

  def set_secret_key_and_iv
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt

    self.secret_key ||= Base64.encode64(cipher.random_key).strip
    self.secret_key_iv ||= Base64.encode64(cipher.random_iv).strip
  end
end
