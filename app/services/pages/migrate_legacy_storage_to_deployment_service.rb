# frozen_string_literal: true

module Pages
  class MigrateLegacyStorageToDeploymentService
    ExclusiveLeaseTakenError = Class.new(StandardError)

    include BaseServiceUtility
    include ::Pages::LegacyStorageLease

    attr_reader :project

    def initialize(project, ignore_invalid_entries: false)
      @project = project
      @ignore_invalid_entries = ignore_invalid_entries
    end

    def execute
      result = try_obtain_lease do
        execute_unsafe
      end

      raise ExclusiveLeaseTakenError, "Can't migrate pages for project #{project.id}: exclusive lease taken" if result.nil?

      result
    end

    private

    def execute_unsafe
      zip_result = ::Pages::ZipDirectoryService.new(project.pages_path, ignore_invalid_entries: @ignore_invalid_entries).execute

      if zip_result[:status] == :error
        if zip_result[:invalid_public] && @ignore_invalid_entries

          unless project.pages_metadatum&.reload&.pages_deployment
            project.mark_pages_as_not_deployed

            return success(message: "Invalid or missing public directory at #{project.pages_path}. Corrected project to be not deployed")
          end

          return success # we can consider project successfully migrated if we have deployment
        end

        return error("Can't create zip archive: #{zip_result[:message]}")
      end

      archive_path = zip_result[:archive_path]

      deployment = nil
      File.open(archive_path) do |file|
        deployment = project.pages_deployments.create!(
          file: file,
          file_count: zip_result[:entries_count],
          file_sha256: Digest::SHA256.file(archive_path).hexdigest
        )
      end

      project.set_first_pages_deployment!(deployment)

      success
    ensure
      FileUtils.rm_f(archive_path) if archive_path
    end
  end
end
