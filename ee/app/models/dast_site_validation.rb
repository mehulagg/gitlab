# frozen_string_literal: true

class DastSiteValidation < ApplicationRecord
  belongs_to :dast_site_token
  has_many :dast_sites

  validates :dast_site_token_id, presence: true
  validates :validation_strategy, presence: true

  scope :by_project_id, -> (project_ids) do
    joins(:dast_site_token).where(dast_site_tokens: { project_id: project_ids })
  end

  scope :url_in, -> (urls) do
    base_urls = urls.map { |url| DastSiteValidation.get_base_url(url) }
    paths = urls.map { |url| DastSiteValidation.get_path(url) }
    where(url_base: base_urls, url_path: paths)
  end

  before_create :set_normalized_url_base

  enum validation_strategy: { text_file: 0 }

  delegate :project, to: :dast_site_token, allow_nil: true

  def validation_url
    "#{url_base}/#{url_path}"
  end

  INITIAL_STATE = :pending

  state_machine :state, initial: INITIAL_STATE do
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

  def self.get_base_url(url)
    uri = URI(url)
    "%{scheme}://%{host}:%{port}" % { scheme: uri.scheme, host: uri.host, port: uri.port }
  end

  def self.get_path(url)
    URI(url).path.sub(/^\//, '')
  end

  private

  def set_normalized_url_base
    self.url_base = DastSiteValidation.get_base_url(dast_site_token.url)
  end
end
