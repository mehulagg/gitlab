# frozen_string_literal: true

module Gitlab
  module GithubImport
    module ErrorTracking
      include ::Gitlab::ErrorTracking

      def self.generate_context_payload(...)
        super.deep_merge(extra: { import_source: :gitlab })
      end
    end
  end
end
