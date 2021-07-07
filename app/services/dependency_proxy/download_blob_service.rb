# frozen_string_literal: true

module DependencyProxy
  class DownloadBlobService < DependencyProxy::BaseService
    def initialize(image, blob_sha, token)
      @image = image
      @blob_sha = blob_sha
      @token = token
      @temp_file = Tempfile.new
    end

    def execute
      File.open(@temp_file.path, "wb") do |file|
        file.unlink

        Gitlab::HTTP.get(blob_url, headers: auth_headers, stream_body: true) do |fragment|
          if [301, 302, 307].include?(fragment.code)
            # do nothing
          elsif fragment.code == 200
            file.write(fragment)
          else
            raise DownloadError.new('Non-success response code on downloading blob fragment', fragment.code)
          end
        end
      end

      success(file: @temp_file)
    rescue DownloadError => exception
      error(exception.message, exception.http_status)
    rescue Timeout::Error => exception
      error(exception.message, 599)
    end

    def execute_with_blob
      raise ArgumentError, 'Block must be provided' unless block_given?

      file = Tempfile.new('dependency_proxy_blob:')
      file.unlink
      begin
        Gitlab::HTTP.get(blob_url, headers: auth_headers, stream_body: true) do |fragment|
          if [301, 302, 307].include?(fragment.code)
            # do nothing
          elsif fragment.code == 200
            file.write(fragment)
          else
            raise DownloadError.new('Non-success response code on downloading blob fragment', fragment.code)
          end
        end

        file.flush
        yield(success(file: @temp_file, content_type: response.headers['content-type']))
      ensure
        file.close
      end
    rescue DownloadError => exception
      error(exception.message, exception.http_status)
    rescue Timeout::Error => exception
      error(exception.message, 599)
    end

    private

    def blob_url
      registry.blob_url(@image, @blob_sha)
    end
  end
end
