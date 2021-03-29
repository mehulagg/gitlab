# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicAwardEmojiPipeline
          include ::BulkImports::Pipeline

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          def initialize(context)
            @context = context
            @next_pages = context.extra[:subrelation_next_pages]
            @batch_size = 15
          end

          def extract(context)
            return if @next_pages.blank?

            batch = @next_pages.pop(@batch_size)

            response = graphql_client.execute(
              graphql_client.parse(query.to_s(batch)),
              query.variables(context)
            ).original_hash.deep_dup

            ::BulkImports::Pipeline::ExtractedData.new(
              data: response.dig(*query.data_path),
              page_info: nil
            )
          end

          def transform(context, data)
            nodes = data.dig('award_emoji', 'nodes')

            return if nodes.blank?

            track_next_page(data)

            data['award_emoji']['nodes'] = nodes.map do |node|
              ::BulkImports::Common::Transformers::UserReferenceTransformer.new.transform(context, node)
            end

            data
          end

          def load(context, data)
            return unless data

            epic = context.group.epics.find_by_iid(data['iid'])

            return unless epic

            raise NotAllowedError unless Ability.allowed?(context.current_user, :award_emoji, epic)

            data.dig('award_emoji', 'nodes').each do |award_emoji|
              next if award_emoji_exists?(epic, award_emoji)

              epic.award_emoji.create!(award_emoji)
            end
          end

          private

          def after_run(extracted_data)
            run unless @next_pages.blank?
          end

          def graphql_client
            @graphql_client ||= ::BulkImports::Clients::Graphql.new(
              url: context.configuration.url,
              token: context.configuration.access_token
            )
          end

          def query
            ::EE::BulkImports::Groups::Graphql::GetEpicAwardEmojiQuery
          end

          def award_emoji_exists?(epic, data)
            epic.award_emoji.exists?(user_id: data['user_id'], name: data['name']) # rubocop: disable CodeReuse/ActiveRecord
          end

          def track_next_page(data)
            page_info = data.dig('award_emoji', 'page_info')

            if page_info['has_next_page']
              epic_iid = data['iid']
              award_emoji_next_page = page_info['next_page']

              @next_pages << [epic_iid, award_emoji_next_page]
            end
          end
        end
      end
    end
  end
end
