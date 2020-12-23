# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class TemplateUsage < Chain::Base
          def perform!
            included_templates.each do |template|
              track_event(template)
            end
          end

          def break?
            false
          end

          private

          def track_event(template)
            Gitlab::UsageDataCounters::CiTemplateUniqueCounter
              .track_unique_project_event(project_id: pipeline.project_id, template: template)
          end

          def includes
            command.yaml_processor_result.includes
          end

          def included_templates
            includes
              .map { |i| i[:template] }
              .compact
          end
        end
      end
    end
  end
end
