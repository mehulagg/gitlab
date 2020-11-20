# frozen_string_literal: true

module MigrationAttributes
  extend ActiveSupport::Concern
  include Gitlab::ClassAttributes

  # This should be set if a migration should be run against data
  # in batches. This is typically the case if large amounts of documents
  # are being added/updated or if the documents are being moved
  # to a new index.
  def batch_update!
    class_attributes[:batch_update] = true
  end

  def batch_update?
    class_attributes[:batch_update]
  end
end
