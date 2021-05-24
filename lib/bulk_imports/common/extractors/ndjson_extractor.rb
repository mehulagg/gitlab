# frozen_string_literal: true

module BulkImports
  module Common
    module Extractors
      class NdjsonExtractor
        include Gitlab::ImportExport::CommandLineUtil
        include Gitlab::Utils::StrongMemoize

        EXPORT_DOWNLOAD_URL_PATH = "/%s/%s/export_relations/download?relation=%s"

        def initialize(options = {})
          @relation = options[:relation]
          @tmp_dir = Dir.mktmpdir
        end

        def extract(context)
          download_service(tmp_dir, context).execute
          decompression_service(tmp_dir).execute
          relations = ndjson_reader(tmp_dir).consume_relation('', relation)

          BulkImports::Pipeline::ExtractedData.new(data: relations)
        end

        def remove_tmp_dir
          FileUtils.remove_entry(tmp_dir)
        end

        private

        attr_reader :relation, :tmp_dir

        def filename
          @filename ||= "#{relation}.ndjson.gz"
        end

        def download_service(tmp_dir, context)
          @download_service ||= BulkImports::FileDownloadService.new(
            configuration: context.configuration,
            relative_url: relative_resource_url(context),
            dir: tmp_dir,
            filename: filename
          )
        end

        def decompression_service(tmp_dir)
          @decompression_service ||= BulkImports::FileDecompressionService.new(
            dir: tmp_dir,
            filename: filename
          )
        end

        def ndjson_reader(tmp_dir)
          @ndjson_reader ||= Gitlab::ImportExport::JSON::NdjsonReader.new(tmp_dir)
        end

        def relative_resource_url(context)
          strong_memoize(:relative_resource_url) do
            resource = context.portable.class.name.downcase.pluralize
            encoded_full_path = context.entity.encoded_source_full_path

            EXPORT_DOWNLOAD_URL_PATH % [resource, encoded_full_path, relation]
          end
        end
      end
    end
  end
end
