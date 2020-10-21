# frozen_string_literal: true

module EE
  module Ci
    module DestroyExpiredJobArtifactsService
      def run_after_destroy(artifacts)
        destroy_security_findings_for(artifacts) if artifacts.first.is_a?(::Ci::JobArtifact)
      end

      def destroy_security_findings_for(artifacts)
        job_ids = artifacts.map(&:job_id)

        ::Security::Finding.by_build_ids(job_ids).delete_all
      end
    end
  end
end
