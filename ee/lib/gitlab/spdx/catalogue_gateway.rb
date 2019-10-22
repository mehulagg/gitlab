# frozen_string_literal: true

module Gitlab
  module SPDX
    class CatalogueGateway
      URL = 'https://spdx.org/licenses/licenses.json'

      def fetch
        response = ::Gitlab::HTTP.get(URL)

        if response.success?
          parse(response.body)
        else
          record_failure(http_status_code: response.code)
          empty_catalogue
        end
      rescue *::Gitlab::HTTP::HTTP_ERRORS => error
        record_failure(error_message: error.message)
        empty_catalogue
      end

      private

      def parse(json)
        build_catalogue(JSON.parse(json, symbolize_names: true))
      end

      def record_failure(tags = {})
        Gitlab::Metrics.add_event(:spdx_fetch_failed, tags)
      end

      def empty_catalogue
        build_catalogue(licenses: [])
      end

      def build_catalogue(hash)
        ::Gitlab::SPDX::Catalogue.new(hash)
      end
    end
  end
end
