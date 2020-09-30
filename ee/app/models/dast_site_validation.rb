# frozen_string_literal: true

class DastSiteValidation < ApplicationRecord
  belongs_to :dast_site_token
  has_many :dast_sites

  validates :dast_site_token_id, presence: true
  validates :validation_strategy, presence: true

  scope :by_project_id, -> (project_id) do
    joins(:dast_site_token).where(dast_site_tokens: { project_id: project_id })
  end

  before_create :set_url_base

  enum validation_strategy: { text_file: 0 }

  delegate :project, to: :dast_site_token, allow_nil: true

  private

  def set_url_base
    uri = URI(dast_site_token.url)

    self.url_base = "%{scheme}://%{host}:%{port}" % { scheme: uri.scheme, host: uri.host, port: uri.port }
  end
end
