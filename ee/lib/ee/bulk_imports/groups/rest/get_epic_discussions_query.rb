# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Rest
        module GetEpicDiscussionsQuery
          extend self

          def to_h(context)
            id = context.extra[:epic_source_id]
            iid = context.extra[:epic_iid]
            tracker = "epic_#{iid}_discussions"
            encoded_full_path = ERB::Util.url_encode(context.entity.source_full_path)

            {
              resource: ['groups', encoded_full_path, 'epics', id, 'discussions'].join('/'),
              query: {
                page: context.entity.next_page_for(tracker)
              }
            }
          end
        end
      end
    end
  end
end
