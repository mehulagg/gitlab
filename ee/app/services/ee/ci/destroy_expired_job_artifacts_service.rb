# frozen_string_literal: true

module EE
  module Ci
    module DestroyExpiredJobArtifactsService
      extend ::Gitlab::Utils::Override

      private

      override :destroy_related_records_for
      def destroy_related_records_for(artifacts)
        destroy_security_findings_for(artifacts)
      end

      def destroy_security_findings_for(artifacts)
        job_ids = artifacts.map(&:job_id)

        ::Security::Finding.by_build_ids(job_ids).delete_all
      end
    end
  end
end
