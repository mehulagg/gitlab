# frozen_string_literal: true

module EE
  module BulkImports
    module Pipeline
      class EpicBase
        include ::BulkImports::Pipeline

        def initialize(context)
          super(context)

          @epic_iids = context.group.epics.order(iid: :desc).pluck(:iid) # rubocop: disable CodeReuse/ActiveRecord

          set_next_epic
        end

        def run
          return skip!('Skipping because group has no epics') if current_epic_iid.blank?

          super
        end

        private

        attr_reader :epic_iids

        def after_run(extracted_data)
          set_next_epic unless extracted_data.has_next_page?

          if has_next_page_or_next_epic?(extracted_data)
            run
          end
        end

        def set_next_epic
          context.extra[:epic_iid] = epic_iids.pop
        end

        def has_next_page_or_next_epic?(extracted_data)
          extracted_data.has_next_page? || current_epic_iid
        end

        def current_epic_iid
          context.extra[:epic_iid]
        end
      end
    end
  end
end
