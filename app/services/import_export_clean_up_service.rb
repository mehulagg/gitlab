# frozen_string_literal: true

class ImportExportCleanUpService
  LAST_MODIFIED_TIME_IN_MINUTES = 1440
  DIR_DEPTH = 5
  CleanUpError = Class.new(StandardError)

  attr_reader :mmin, :path

  def initialize(mmin = LAST_MODIFIED_TIME_IN_MINUTES)
    @mmin = mmin
    @path = Gitlab::ImportExport.storage_path
  end

  def execute
    Gitlab::Metrics.measure(:import_export_clean_up) do
      execute_cleanup
    end
  end

  private

  def execute_cleanup
    clean_up_export_object_files
  ensure
    # We don't want a failure in cleaning up object storage from
    # blocking us from cleaning up temporary storage.
    clean_up_export_files if File.directory?(path)
  end

  def clean_up_export_files
    old_directories do |dir|
      if dir.start_with?(path)
        FileUtils.remove_entry(dir)

        logger.info(
          message: 'Removed Import/Export tmp directory',
          dir_path: dir
        )
      end
    end
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def clean_up_export_object_files
    ImportExportUpload.where('updated_at < ?', mmin.minutes.ago).each do |upload|
      upload.remove_export_file!
      upload.save!

      logger.info(
        message: 'Removed ImportExportUpload#export_file',
        project_id: upload.project_id,
        group_id: upload.group_id
      )
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def old_directories
    IO.popen(directories_cmd) do |find|
      find.each_line do |directory|
        yield directory
      end
    end
  end

  def directories_cmd
    %W(find #{path} -not -path #{path} -type d -mindepth #{DIR_DEPTH} -maxdepth #{DIR_DEPTH} -mmin +#{mmin})
  end

  def logger
    @logger ||= Gitlab::Import::Logger.build
  end
end
