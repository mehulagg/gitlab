# frozen_string_literal: true

module Geo
  class RegistryFinder
    # @!method find_registries_never_attempted_sync
    #    Return an ActiveRecord::Relation of the registry records for the
    #    tracked type that this secondary has never attempted to sync.
    #
    #    Does not care about selective sync, because it considers the Registry
    #    table to be the single source of truth. The contract is that other
    #    processes need to ensure that the table only contains records that should
    #    be synced.
    #
    #    Any registries that this secondary has ever attempted to sync that currently need to be
    #    resynced will be handled by other find methods (like
    #    #find_registries_needs_sync_again)
    #
    #    You can pass a list with `except_ids:` so you can exclude items you
    #    already scheduled but haven't finished and aren't persisted to the database yet
    #
    # @param [Integer] batch_size used to limit the results returned
    # @param [Array<Integer>] except_ids ids that will be ignored from the query
    #
    def find_registries_never_attempted_sync(batch_size:, except_ids: [])
      registry_class
        .find_registries_never_attempted_sync(batch_size: batch_size, except_ids: except_ids)
    end

    # @!method find_registries_needs_sync_again
    #    Return an ActiveRecord::Relation of registry records marked as failed,
    #    which are ready to be retried, excluding specified IDs, limited to
    #    batch_size
    #
    # @param [Integer] batch_size used to limit the results returned
    # @param [Array<Integer>] except_ids ids that will be ignored from the query
    #
    def find_registries_needs_sync_again(batch_size:, except_ids: [])
      registry_class
        .find_registries_needs_sync_again(batch_size: batch_size, except_ids: except_ids)
    end

    # @!method registry_count
    #    Return a count of the registry records for the tracked type(s)
    def registry_count
      registry_class.count
    end

    # @!method synced_count
    #    Return a count of the registry records for the tracked type
    #    that are synced
    def synced_count
      registry_class.synced.count
    end

    # @!method failed_count
    #    Return a count of the registry records for the tracked type
    #    that are sync failed
    def failed_count
      registry_class.failed.count
    end

    # @!method registry_class
    #    Return an ActiveRecord::Base class for the tracked type
    def registry_class
      raise NotImplementedError,
        "#{self.class} does not implement #{__method__}"
    end
  end
end
