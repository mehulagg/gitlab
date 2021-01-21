# frozen_string_literal: true

module EE
  module Ci
    module Metadatable
      extend ActiveSupport::Concern

      prepended do
        delegate :secrets?, :secrets, to: :metadata, prefix: false, allow_nil: true
      end

      def secrets=(value)
        ensure_metadata.secrets = value
      end
    end
  end
end
