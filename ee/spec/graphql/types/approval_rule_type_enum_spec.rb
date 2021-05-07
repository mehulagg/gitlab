# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ApprovalRuleType'] do
  it 'has the correct members' do
    expect(described_class.values).to match(
      'REGULAR' => have_attributes(
        description: 'A `regular` approval rule.',
        value: 'regular'
      ),
      'CODE_OWNER' => have_attributes(
        description: 'A `code_owner` approval rule.',
        value: 'code_owner'
      ),
      'REPORT_APPROVER' => have_attributes(
        description: 'A `report_approver` approval rule.',
        value: 'report_approver'
      ),
      'ANY_APPROVER' => have_attributes(
        description: 'A `any_approver` approval rule.',
        value: 'any_approver'
      )
    )
  end
end
