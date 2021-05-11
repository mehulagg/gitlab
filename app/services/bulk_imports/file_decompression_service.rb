# frozen_string_literal: true

module BulkImports
  class FileDecompressionService
    include Gitlab::ImportExport::CommandLineUtil

    FileDecompressionError = Class.new(StandardError)

    def initialize(dir:, filename:)
      @dir = dir
      @filename = filename
      @filepath = File.join(@dir, @filename)
    end

    def execute
      validate_decompressed_file_size if Feature.enabled?(:validate_import_decompressed_archive_size)

      decompress_file
    end

    private

    attr_reader :dir, :filename, :filepath

    def validate_decompressed_file_size
      raise FileDecompressionError unless size_validator.valid?
    end

    def size_validator
      @size_validator ||= Gitlab::ImportExport::DecompressedArchiveSizeValidator.new(archive_path: filepath)
    end

    def decompress_file
      gunzip(dir: dir, filename: filename)
    end
  end
end
