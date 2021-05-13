# frozen_string_literal: true

module Geo
  class UploadDeletedEvent < NamespaceShard
    include Geo::Model
    include Geo::Eventable

    belongs_to :upload

    validates :upload, :file_path, :model_id, :model_type, :uploader, presence: true

    def upload_type
      uploader&.sub(/Uploader\z/, '')&.underscore
    end
  end
end
