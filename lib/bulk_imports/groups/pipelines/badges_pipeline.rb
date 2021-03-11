# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class BadgesPipeline
        include Pipeline

        extractor BulkImports::Common::Extractors::RestExtractor,
          query: BulkImports::Groups::Rest::GetBadgesQuery

        transformer Common::Transformers::ProhibitedAttributesTransformer

        def transform(_, data)
          return unless data

          {
            name: data['name'],
            link_url: data['link_url'],
            image_url: data['image_url']
          }
        end

        def load(context, data)
          return unless data

          context.group.badges.create!(data)
        end

        def after_run(extracted_data)
          context.entity.update_tracker_for(
            relation: :badges,
            has_next_page: extracted_data.has_next_page?,
            next_page: extracted_data.next_page
          )

          if extracted_data.has_next_page?
            run
          end
        end
      end
    end
  end
end
