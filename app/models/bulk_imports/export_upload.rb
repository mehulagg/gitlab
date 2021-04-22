# frozen_string_literal: true

module BulkImports
  class ExportUpload < ApplicationRecord
    self.table_name = 'bulk_import_export_uploads'

    include WithUploads
    include ObjectStorage::BackgroundMove

    belongs_to :export, class_name: 'BulkImports::Export'

    mount_uploader :export_file, ExportUploader

    def retrieve_upload(_identifier, paths)
      Upload.find_by(model: self, path: paths)
    end
  end
end
