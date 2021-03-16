# frozen_string_literal: true

module EE
  module Ci
    module JobArtifacts
      module DestroyBatchService
        extend ::Gitlab::Utils::Override

        private

        override :destroy_related_records
        def destroy_related_records(artifacts)
          destroy_security_findings(artifacts)
        end

        def destroy_security_findings(artifacts)
          job_ids = artifacts.map(&:job_id)

          ::Security::Finding.by_build_ids(job_ids).delete_all
        end
      end
    end
  end
end
