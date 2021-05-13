# frozen_string_literal: true

module Geo
  class HashedStorageAttachmentsEvent < NamespaceShard
    include Geo::Model
    include Geo::Eventable

    belongs_to :project

    validates :project, :old_attachments_path, :new_attachments_path, presence: true
  end
end
