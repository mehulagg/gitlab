# frozen_string_literal: true

module EE
  module LoadedInGroupList
    extend ActiveSupport::Concern

    class_methods do
      def with_selects_for_list(archived: nil)
        super.preload(:deletion_schedule)
      end
    end
  end
end
