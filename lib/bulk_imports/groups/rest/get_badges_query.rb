# frozen_string_literal: true

module BulkImports
  module Groups
    module Rest
      module GetBadgesQuery
        extend self

        def to_h(context)
          encoded_full_path = ERB::Util.url_encode(context.entity.source_full_path)

          {
            resource: ['groups', encoded_full_path, 'badges'].join('/'),
            query: {
              page: context.entity.next_page_for(:badges)
            }
          }
        end
      end
    end
  end
end
