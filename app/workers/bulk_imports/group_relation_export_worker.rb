# frozen_string_literal: true


# Export a single top level group relation to .ndjson file
# and send it to the provided URL
#
# @example
#   BulkImports::GroupRelationExportWorker.new.perform(group.id, user.id, 'epics', 'https://gitlab.example/')
#
module BulkImports
  class GroupRelationExportWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include ExceptionBacktrace

    feature_category :importers
    loggable_arguments 2
    sidekiq_options retry: false, dead: false

    def perform(group_id, user_id, relation, url)
      # validate user permissions here
      # validate url here

      @group = ::Group.find(group_id)
      @shared = ::Gitlab::ImportExport::Shared.new(@group)
      @url = url
      @export_path = @shared.export_path
      @filename = "#{relation}.ndjson"
      @relation = group_tree[:include].find { |include| include[relation.to_sym] }

      if @relation
        serialize_relation
        send_file
      end

    ensure
      # FileUtils.rm_rf(@shared.archive_path) if @shared&.archive_path
    end

    def serialize_relation
      ::Gitlab::ImportExport::JSON::StreamingSerializer.new(
        @group,
        group_tree,
        json_writer,
        exportable_path: ''
      ).serialize_relation(@relation)
    end

    # Copied from `Gitlab::ImportExport::AfterExportStrategies::WebUploadStrategy`
    def send_file
      file = File.open(File.join(@export_path, @filename))
      options = {
        body_stream: file,
        headers: {
          'Content-Type' => 'application/x-ndjson',
          'Content-Length' => file.size.to_s
        }
      }

      Gitlab::HTTP.put(@url, options) # rubocop:disable GitlabSecurity/PublicSend
    ensure
      file.close
    end

    def group_tree
      @group_tree ||= ::Gitlab::ImportExport::Reader.new(
        shared: @shared,
        config: group_config
      ).group_tree
    end

    def group_config
      ::Gitlab::ImportExport::Config.new(
        config: ::Gitlab::ImportExport.group_config_file
      ).to_h
    end

    def json_writer
      @json_writer ||= Gitlab::ImportExport::JSON::NdjsonWriter.new(@export_path)
    end
  end
end
