module Boards
  module Listable
    extend ActiveSupport::Concern

    included do
      validates :label, :position, presence: true, if: :label?
      validates :label_id, uniqueness: { scope: :board_id }, if: :label?
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :movable?

      scope :ordered, -> { order(:list_type, :position) }
      scope :destroyable, -> { where(list_type: list_types.slice(*destroyable_types).values) }
      scope :movable, -> { where(list_type: list_types.slice(*movable_types).values) }
    end

    class_methods do
      def destroyable_types
        [:label]
      end

      def movable_types
        [:label]
      end
    end

    def destroyable?
      self.class.destroyable_types.include?(list_type&.to_sym)
    end

    def movable?
      self.class.movable_types.include?(list_type&.to_sym)
    end

    def title
      label? ? label.name : list_type.humanize
    end
  end
end
