# frozen_string_literal: true

module BulkImports
  class ExportService
    def initialize(exportable:, user:)
      @exportable = exportable
      @current_user = user
    end

    def execute
      validate_user_permissions

      ExportWorker.perform_async(current_user.id, exportable.id, exportable.class.name)

      ServiceResponse.success
    rescue => e
      ServiceResponse.error(
        message: e.class,
        http_status: :unprocessable_entity
      )
    end

    private

    attr_reader :exportable, :current_user

    def validate_user_permissions
      permission = if exportable.is_a?(::Group)
                     :admin_group
                   elsif exportable.is_a?(::Project)
                     :admin_project
                   else
                     ''
                   end

      unless current_user.can?(permission, exportable)
        raise ::Gitlab::ImportExport::Error.permission_error(current_user, group)
      end
    end
  end
end
