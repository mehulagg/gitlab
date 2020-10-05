# frozen_string_literal: true

class DastSiteValidation < ApplicationRecord
  HEADER = 'Gitlab-On-Demand-DAST'.freeze

  belongs_to :dast_site_token
  has_many :dast_sites

  validates :dast_site_token_id, presence: true
  validates :validation_strategy, presence: true

  scope :by_project_id, -> (project_id) do
    joins(:dast_site_token).where(dast_site_tokens: { project_id: project_id })
  end

  before_create :set_normalized_url_base

  enum validation_strategy: { text_file: 0, header: 1 }

  delegate :project, to: :dast_site_token, allow_nil: true

  def validation_url
    "#{url_base}/#{url_path}"
  end

  state_machine :state, initial: :pending do
    event :start do
      transition pending: :inprogress
    end

    event :retry do
      transition failed: :inprogress
    end

    event :fail_op do
      transition any - :failed => :failed
    end

    event :pass do
      transition inprogress: :passed
    end

    before_transition pending: :inprogress do |validation|
      validation.validation_started_at = Time.now.utc
    end

    before_transition failed: :inprogress do |validation|
      validation.validation_last_retried_at = Time.now.utc
    end

    before_transition any - :failed => :failed do |validation|
      validation.validation_failed_at = Time.now.utc
    end

    before_transition inprogress: :passed do |validation|
      validation.validation_passed_at = Time.now.utc
    end
  end

  private

  def set_normalized_url_base
    uri = URI(dast_site_token.url)

    self.url_base = "%{scheme}://%{host}:%{port}" % { scheme: uri.scheme, host: uri.host, port: uri.port }
  end
end
