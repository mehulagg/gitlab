# frozen_string_literal: true

module BulkImports
  class RelationExportService
    include Gitlab::ImportExport::CommandLineUtil

    def initialize(export)
      @export = export
      @exportable = export.exportable
      @config = export.config
      @export_path = @config.export_path
      @exportable_tree = @config.exportable_tree
    end

    def execute
      remove_existing_export_file
      serialize_relation
      compress_exported_relation
      upload_compressed_file
    ensure
      FileUtils.rm_rf(export_path) if export_path
    end

    private

    attr_reader :current_user, :export, :exportable, :export_path, :exportable_tree

    def remove_existing_export_file
      upload = export.upload

      return unless upload
      return unless upload.export_file&.file

      upload.remove_export_file!
      upload.save!
    end

    # rubocop: disable CodeReuse/Serializer
    def serializer
      @serializer ||= ::Gitlab::ImportExport::JSON::StreamingSerializer.new(
        exportable,
        exportable_tree,
        json_writer,
        exportable_path: ''
      )
    end
    # rubocop: enable CodeReuse/Serializer

    def json_writer
      @json_writer ||= ::Gitlab::ImportExport::JSON::NdjsonWriter.new(export_path)
    end

    def serialize_relation
      serializer.serialize_relation(export.relation_definition)
    end

    def compress_exported_relation
      gzip(dir: export_path, filename: ndjson_filename)
    end

    def upload_compressed_file
      compressed_filename = File.join(export_path, "#{ndjson_filename}.gz")
      upload = ExportUpload.find_or_initialize_by(export_id: export.id) # rubocop: disable CodeReuse/ActiveRecord

      File.open(compressed_filename) { |file| upload.export_file = file }

      upload.save!
    end

    def ndjson_filename
      "#{export.relation}.ndjson"
    end
  end
end
