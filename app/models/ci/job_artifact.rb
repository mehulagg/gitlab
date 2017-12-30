module Ci
  class JobArtifact < ActiveRecord::Base
    include AfterCommitQueue
    extend Gitlab::Ci::Model

    TRACE_FILE_NAME = 'trace.log'.freeze

    belongs_to :project
    belongs_to :job, class_name: "Ci::Build", foreign_key: :job_id

    before_save :set_size, if: :file_changed?

    mount_uploader :file, JobArtifactUploader

    after_save if: :file_changed?, on: [:create, :update] do
      run_after_commit do
        file.schedule_migration_to_object_storage
      end
    end

    enum file_type: {
      archive: 1,
      metadata: 2,
      trace: 3
    }

    def self.artifacts_size_for(project)
      self.where(project: project).sum(:size)
    end

    def set_size
      self.size = file.size
    end

    def expire_in
      expire_at - Time.now if expire_at
    end

    def expire_in=(value)
      self.expire_at =
        if value
          ChronicDuration.parse(value)&.seconds&.from_now
        end
    end
  end
end
