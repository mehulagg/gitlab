# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Trace
        extend ::Gitlab::Utils::Override

        override :destroy_stream
        def destroy_stream(build)
          if consistent_archived_trace?(build)
            ::Gitlab::Database::LoadBalancing::Sticking
              .stick('ci/build/trace', build.id)
          end

          yield
        end

        override :read_trace_artifact
        def read_trace_artifact(build)
          if consistent_archived_trace?(build)
            ::Gitlab::Database::LoadBalancing::Sticking
              .unstick_or_continue_sticking('ci/build/trace', build.id)
          end

          yield
        end

        def consistent_archived_trace?(build)
          ::Feature.enabled?(:gitlab_ci_archived_trace_consistent_reads, build.project, default_enabled: false)
        end
      end
    end
  end
end
