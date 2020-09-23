# frozen_string_literal: true

module Geo
  class LfsObjectDeletedEventStore < EventStore
    extend ::Gitlab::Utils::Override

    self.event_type = :lfs_object_deleted_event

    attr_reader :lfs_object

    def initialize(lfs_object)
      @lfs_object = lfs_object
    end

    private

    def build_event
      Geo::LfsObjectDeletedEvent.new(
        lfs_object: lfs_object,
        oid: lfs_object.oid,
        file_path: relative_file_path
      )
    end

    def relative_file_path
      lfs_object.file.relative_path if lfs_object.file.present?
    end

    # This is called by LogHelpers to build json log with context info
    #
    # @see ::Gitlab::Geo::LogHelpers
    def extra_log_data
      {
        lfs_object_id: lfs_object.id,
        file_path: lfs_object.file.path
      }.compact
    end
  end
end
