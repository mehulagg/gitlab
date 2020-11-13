# frozen_string_literal: true

module Pages
  class ExclusiveLeaseTaken < StandardError
    def initialize(lease_key, project_id)
      @lease_key = lease_key
      @project_id = project_id
    end

    def message
      "Exclusive lease #{@lease_key} for project #{@project_id} is already taken."
    end
  end

  module LegacyStorageLease
    extend ActiveSupport::Concern

    def with_exclusive_lease
      lease_key = exclusive_lease_key
      uuid = Gitlab::ExclusiveLease.new(lease_key, timeout: 1.hour.to_i).try_obtain
      raise ExclusiveLeaseTaken.new(lease_key) unless uuid

      yield uuid
    ensure
      Gitlab::ExclusiveLease.cancel(lease_key, uuid)
    end

    def exclusive_lease_key
      "pages_legacy_storage:#{project.id}"
    end
  end
end
