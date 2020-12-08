# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Pipeline
          module Index
            extend QA::Page::PageConcern

            def wait_for_latest_pipeline_replication
              QA::Runtime::Logger.debug(%Q[#{self.class.name} - wait_for_latest_pipeline_replication])
              wait_until(max_duration: Runtime::Geo.max_file_replication_time) do
                within_element(:pipeline_commit_status, index: 0) { has_text?(/passed|failed/) }
              end
            end
          end
        end
      end
    end
  end
end
