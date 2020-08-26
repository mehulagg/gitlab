# frozen_string_literal: true

module Gitlab
  module ImportExport
    module AfterExportStrategies
      class ExportCallbackStrategy < BaseAfterExportStrategy
        protected

        def delete_export?
          false
        end

        private

        def strategy_execute
          # callback to the destination endpoint
          client = ::ImportExport::GitlabClient.new(host: callback_host)

          client.notify_export(
            importable_type: 'project',
            importable_id: project.id,
            destination_group_id: destination_group_id,
            params: {
              path: project_path,
              name: project.name
            }
          )
        end
      end
    end
  end
end
