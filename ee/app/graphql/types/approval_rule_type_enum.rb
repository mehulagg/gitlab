# frozen_string_literal: true

module Types
  class ApprovalRuleTypeEnum < BaseEnum
    # See: ApprovalMergeRequestRule, and ApprovalProjectRule
    graphql_name 'ApprovalRuleType'
    description 'The kind of an approval rule.'

    from_rails_enum(
      ApprovalProjectRule.rule_types.merge(ApprovalMergeRequestRule.rule_types),
      description: 'A `%{name}` approval rule.'
    )
  end
end
