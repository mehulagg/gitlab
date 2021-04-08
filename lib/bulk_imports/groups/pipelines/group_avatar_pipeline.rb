# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class GroupAvatarPipeline
        include Pipeline
        include ::Gitlab::ImportExport::CommandLineUtil

        TMP_DIR = File.join(Rails.root, 'public/uploads/tmp')
        MAX_FILESIZE = 200.kilobytes.to_i

        extractor Common::Extractors::GraphqlExtractor, query: Graphql::GetGroupAvatarQuery

        # Transform URL into a Tempfile on disk
        def transform(context, data)
          avatar_url = data['avatar_url']

          Gitlab::UrlBlocker.validate!(avatar_url, allow_localhost: false, allow_local_network: false, schemes: %w(http https))

          uri = URI.parse(avatar_url)

          name = [File.basename(f.path), File.extname(f.base_uri.path)]
          open_uri_file = uri.open(
            redirect: false,
            http_basic_authentication: basic_auth,
            content_length_proc: ->() {

            }
          )
          extension = File.extname(open_uri_file.base_uri.path)



        end

        def load(context, file)
          return unless file

          Groups::UpdateService.new(context.group, context.current_user, { avatar: file }).execute
        end

        private

        def basic_auth
          [context.configuration]
        end
      end
    end
  end
end
