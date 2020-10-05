# frozen_string_literal: true

module EE
  module List
    extend ::Gitlab::Utils::Override

    include ::Gitlab::Utils::StrongMemoize

    LIMIT_METRIC_TYPES = %w[all_metrics issue_count issue_weights].freeze

    # ActiveSupport::Concern does not prepend the ClassMethods,
    # so we cannot call `super` if we use it.
    def self.prepended(base)
      base.include(UsageStatistics)

      class << base
        prepend ClassMethods
      end

      base.belongs_to :user
      base.belongs_to :milestone

      base.validates :user, presence: true, if: :assignee?
      base.validates :milestone, presence: true, if: :milestone?
      base.validates :user_id, uniqueness: { scope: :board_id }, if: :assignee?
      base.validates :milestone_id, uniqueness: { scope: :board_id }, if: :milestone?
      base.validates :max_issue_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      base.validates :max_issue_weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      base.validates :limit_metric, inclusion: {
          in: LIMIT_METRIC_TYPES,
          allow_blank: true,
          allow_nil: true
      }
      base.validates :list_type,
        exclusion: { in: %w[assignee], message: _('Assignee lists not available with your current license') },
        unless: -> { board&.resource_parent&.feature_available?(:board_assignee_lists) }
      base.validates :list_type,
        exclusion: { in: %w[milestone], message: _('Milestone lists not available with your current license') },
        unless: -> { board&.resource_parent&.feature_available?(:board_milestone_lists) }

      base.scope :without_types, ->(list_types) { where.not(list_type: list_types) }
    end

    def assignee=(user)
      self.user = user
    end

    def wip_limits_available?
      strong_memoize(:wip_limits_available) do
        board.resource_parent.feature_available?(:wip_limits)
      end
    end

    override :title
    def title
      case list_type
      when 'assignee'
        user.to_reference
      when 'milestone'
        milestone.title
      else
        super
      end
    end

    override :as_json
    def as_json(options = {})
      super.tap do |json|
        if options.key?(:user)
          json[:user] = UserSerializer.new.represent(user).as_json
        end

        if options.key?(:milestone)
          json[:milestone] = MilestoneSerializer.new.represent(milestone).as_json
        end
      end
    end

    module ClassMethods
      def destroyable_types
        super + [:assignee, :milestone]
      end

      def movable_types
        super + [:assignee, :milestone]
      end
    end
  end
end
