# frozen_string_literal: true

module EE
  module Labels
    module PromoteService
      extend ::Gitlab::Utils::Override

      private

      override :update_old_label_relations
      def update_old_label_relations(new_label, old_label_ids)
        super

        update_board_scopes(new_label, old_label_ids)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def update_board_scopes(new_label, old_label_ids)
        BoardLabel
          .where(label: old_label_ids)
          .update_all(label_id: new_label.id)
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
