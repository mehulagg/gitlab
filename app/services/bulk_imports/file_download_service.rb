# frozen_string_literal: true

module BulkImports
  class FileDownloadService
    FILE_SIZE_LIMIT = 5.gigabytes
    ALLOWED_CONTENT_TYPES = ['application/gzip'].freeze

    ContentTypeError = Class.new(StandardError)
    ContentLengthError = Class.new(StandardError)
    FileDownloadError = Class.new(StandardError)

    def initialize(configuration:, relative_url:, dir:, filename:)
      @configuration = configuration
      @relative_url = relative_url
      @filename = filename
      @dir = dir
      @filepath = File.join(@dir, @filename)
    end

    def execute
      validate_url
      validate_content_length
      validate_content_type

      download_file
    end

    private

    attr_reader :configuration, :relative_url, :dir, :filename, :filepath

    def download_file
      File.open(filepath, 'wb') do |file|
        bytes_downloaded = 0

        response = http_client.stream(relative_url) do |chunk|
          bytes_downloaded += chunk.size

          raise FileDownloadError if bytes_downloaded > FILE_SIZE_LIMIT

          next unless chunk.code == 200

          file.write(chunk)
        end

        raise FileDownloadError unless response.success?
      end
    end

    def http_client
      @http_client ||= BulkImports::Clients::Http.new(
        uri: configuration.url,
        token: configuration.access_token
      )
    end

    def validate_url
      ::Gitlab::UrlBlocker.validate!(
        http_client.resource_url(relative_url),
        allow_localhost: allow_local_requests?,
        allow_local_network: allow_local_requests?,
        schemes: %w(http https)
      )
    end

    def allow_local_requests?
      ::Gitlab::CurrentSettings.allow_local_requests_from_web_hooks_and_services?
    end

    def validate_content_length
      content_size = headers['content-length']

      raise ContentLengthError if content_size.blank? || content_size.to_i > FILE_SIZE_LIMIT
    end

    def validate_content_type
      content_type = headers['content-type']

      raise ContentTypeError if content_type.blank? || ALLOWED_CONTENT_TYPES.exclude?(content_type)
    end

    def headers
      @headers ||= http_client.head(relative_url).headers
    end
  end
end
