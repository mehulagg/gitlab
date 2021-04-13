# frozen_string_literal: true

module BulkImports
  class ExportUpload < ApplicationRecord
    self.table_name = 'bulk_import_export_uploads'

    include WithUploads
    include ObjectStorage::BackgroundMove

    belongs_to :project
    belongs_to :group

    validates :group, presence: true, unless: :project
    validates :project, presence: true, unless: :group

    mount_uploader :export_file, ExportUploader

    def retrieve_upload(_identifier, paths)
      Upload.find_by(model: self, path: paths)
    end
  end
end
