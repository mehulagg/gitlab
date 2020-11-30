# frozen_string_literal: true

module DependencyProxy
  class PullManifestService < DependencyProxy::BaseService
    def initialize(image, tag, token)
      @image = image
      @tag = tag
      @token = token
      @temp_file = Tempfile.new
    end

    def execute
      response = Gitlab::HTTP.get(manifest_url, headers: auth_headers)

      if response.success?
        File.open(@temp_file.path, "wb") do |file|
          file.write(response)
        end

        success(file: @temp_file, digest: response.headers['docker-content-digest'])
      else
        error(response.body, response.code)
      end
    rescue Timeout::Error => exception
      error(exception.message, 599)
    rescue DownloadError => exception
      error(exception.message, exception.http_status)
    end

    private

    def manifest_url
      registry.manifest_url(@image, @tag)
    end
  end
end
