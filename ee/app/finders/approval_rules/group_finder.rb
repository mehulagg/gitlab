# frozen_string_literal: true

# For caching group related queries relative to current_user
module ApprovalRules
  class GroupFinder
    attr_reader :rule, :current_user

    def initialize(rule, user)
      @rule = rule
      @current_user = user
    end

    def visible_groups
      @visible_groups ||= groups.public_or_visible_to_user(current_user)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def hidden_groups
      @hidden_groups ||= groups.where.not(id: visible_groups.map(&:id))
    end

    def contains_hidden_groups?
      hidden_groups.loaded? ? hidden_groups.present? : hidden_groups.exists?
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def groups
      return Group.none if rule.any_approver?

      rule.groups
    end
  end
end
