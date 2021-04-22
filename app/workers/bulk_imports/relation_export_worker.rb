# frozen_string_literal: true

module BulkImports
  class RelationExportWorker
    include ApplicationWorker
    include ExceptionBacktrace

    idempotent!
    loggable_arguments 2, 3
    feature_category :importers
    sidekiq_options status_expiration: StuckExportJobsWorker::EXPORT_JOBS_EXPIRATION

    def perform(user_id, exportable_id, exportable_class, relation)
      user = User.find(user_id)
      exportable = exportable(exportable_id, exportable_class)

      export = exportable.bulk_import_exports.safe_find_or_create_by!(relation: relation)
      export.config.validate_user_permissions(user)
      export.update!(status_event: 'start', jid: jid)

      RelationExportService.new(export).execute

      export.finish!
    rescue => e
      Gitlab::ErrorTracking.track_exception(e, exportable_id: exportable&.id, exportable_type: exportable&.class&.name)

      export&.update(status_event: 'fail_op', error: e.class)
    end

    private

    def exportable(exportable_id, exportable_class)
      case exportable_class
      when ::Project.name
        ::Project.find(exportable_id)
      when ::Group.name
        ::Group.find(exportable_id)
      else
        raise ::Gitlab::ImportExport::Error.unsupported_object_type_error
      end
    end
  end
end
