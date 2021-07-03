# frozen_string_literal: true

class LfsDownloadObject
  include ActiveModel::Validations

  attr_accessor :oid, :size, :link, :headers
  delegate :sanitized_url, :credentials, to: :sanitized_uri

  validates :oid, format: { with: /\A\h{64}\z/ }
  validates :size, numericality: { greater_than_or_equal_to: 0 }
  validates :link, public_url: { protocols: %w(http https) }

  def initialize(oid:, size:, link:, headers:)
    @oid = oid
    @size = size
    @link = link
    @headers = headers || {}
  end

  def sanitized_uri
    @sanitized_uri ||= Gitlab::UrlSanitizer.new(link)
  end
end
