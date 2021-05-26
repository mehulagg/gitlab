# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class GroupAvatarPipeline
        include Pipeline

        class AvatarDownloadService < BulkImports::FileDownloadService
          FILE_SIZE_LIMIT = Avatarable::MAXIMUM_FILE_SIZE

          def initialize(configuration:, relative_url:, dir: Dir.mktmpdir, filename: '')
            super
          end

          def execute
            validate_url
            validate_dir

            @filename = headers['x-gitlab-avatar-filename']
            @filepath = File.join(@dir, @filename)

            validate_content_type
            validate_content_length

            download_file

            validate_symlink

            filepath
          end
        end
        private_constant :AvatarDownloadService

        def extract(context)
          filepath = AvatarDownloadService.new(
            configuration: context.configuration,
            relative_url: "/groups/#{context.entity.source_full_path}/avatar"
          ).execute

          BulkImports::Pipeline::ExtractedData.new(data: { filepath: filepath })
        end

        def transform(_, data)
          data
        end

        def load(context, data)
          return if data.blank?

          ::Groups::UpdateService.new(
            context.group,
            context.current_user,
            avatar: File.open(data[:filepath])
          ).execute
        end
      end
    end
  end
end
