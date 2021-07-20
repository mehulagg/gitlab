# frozen_string_literal: true

module AppSec
  module Dast
    module Buildable
      extend ::ActiveSupport::Concern

      included do
        extend SuppressCompositePrimaryKeyWarning

        validate :project_ids_match
      end

      def project_ids_match
        return if ci_build.nil? || profile.nil?

        unless ci_build.project_id == profile.project_id
          errors.add(:ci_build_id, "project_id must match #{profile.class.underscore}.project_id")
        end
      end
    end
  end
end
