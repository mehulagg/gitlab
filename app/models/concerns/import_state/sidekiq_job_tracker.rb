# frozen_string_literal: true

module ImportState
  module SidekiqJobTracker
    extend ActiveSupport::Concern

    included do
      # Refreshes the expiration time of the associated import job ID.
      #
      # This method can be used by asynchronous importers to refresh the status,
      # preventing the StuckImportJob workers from marking the import as failed.
      def refresh_jid_expiration
        return unless jid

        Gitlab::SidekiqStatus.set(jid, ::Gitlab::Import::StuckImportJob::IMPORT_JOBS_EXPIRATION)
      end

      def self.jid_by(project_id:, status:)
        select(:jid).where(status: status).find_by(project_id: project_id)
      end
    end
  end
end
