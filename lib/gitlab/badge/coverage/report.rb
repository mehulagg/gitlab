# frozen_string_literal: true

module Gitlab
  module Badge
    module Coverage
      ##
      # Test coverage report badge
      #
      class Report < Badge::Base
        attr_reader :project, :ref, :job, :customization

        def initialize(project, ref, opts: { job: nil })
          @project = project
          @ref = ref
          @job = opts[:job]
          @customization = {
            key_width: opts[:key_width].to_i,
            key_text: opts[:key_text]
          }
        end

        def entity
          'coverage'
        end

        def status
          @coverage ||= raw_coverage
          return unless @coverage

          @coverage.to_f.round(2)
        end

        def metadata
          @metadata ||= Coverage::Metadata.new(self)
        end

        def template
          @template ||= Coverage::Template.new(self)
        end

        private

        def pipeline
          @pipeline ||= @project.ci_pipelines.latest_successful_for_ref(@ref)
        end

        def raw_coverage
          if @job.present?
            @project.builds.latest.success.for_ref(@ref).by_name(@job).order_id_desc.first&.coverage
          else
            @project.ci_pipelines.latest_successful_for_ref(@ref)&.coverage
          end
        end
      end
    end
  end
end
