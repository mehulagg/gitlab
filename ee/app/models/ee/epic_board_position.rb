# frozen_string_literal: true

module EE
  module EpicBoardPosition
    extend ActiveSupport::Concern

    prepended do
      include RelativePositioning

      belongs_to :board
      belongs_to :epic

      validates :board, presence: true
      validates :epic, presence: true, uniqueness: { scope: :board_id }

      alias_attribute :parent, :board

      scope :order_relative_position, -> do
        reorder('relative_position ASC', 'id DESC')
      end
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      def relative_positioning_query_base(position)
        where(board_id: position.board_id)
      end

      def relative_positioning_parent_column
        :board_id
      end
    end
  end
end
