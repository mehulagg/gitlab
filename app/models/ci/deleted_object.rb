# frozen_string_literal: true

module Ci
  class DeletedObject < ApplicationRecord
    extend Gitlab::Ci::Model

    mount_uploader :file, DeletedObjectUploader

    scope :ready_for_pickup, -> { where('pick_up_at < ?', Time.current) }
    scope :for_update_skip_locked, -> { lock('FOR UPDATE SKIP LOCKED') }
    scope :for_relationship, ->(objects) { id_in(objects.ids) }
    scope :ordered, -> { order(:pick_up_at) }
    scope :ready_for_destruction, ->(limit) { ready_for_pickup.limit(limit) }
    scope :lock_for_destruction, ->(limit) do
      ready_for_destruction(limit)
        .for_update_skip_locked
        .ordered
    end

    def self.bulk_import(artifacts)
      attributes = artifacts.each.with_object([]) do |artifact, accumulator|
        record = artifact.to_deleted_object_attrs
        accumulator << record if record[:store_dir] && record[:file]
      end

      self.insert_all(attributes) if attributes.any?
    end
  end
end
