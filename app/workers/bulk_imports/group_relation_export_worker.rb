# frozen_string_literal: true

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
      @export_path = @shared.export_path
      @filename = "#{relation}.ndjson"
      @relation = group_tree[:include].find { |include| include[relation.to_sym] }

      if @relation
        serialize_relation
        send_file
      end

      require 'byebug'; byebug
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

    def send_file

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
