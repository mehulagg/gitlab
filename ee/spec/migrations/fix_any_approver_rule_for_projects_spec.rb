# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe FixAnyApproverRuleForProjects do
  let(:namespaces) { table(:namespaces) }
  let(:namespace) { namespaces.create(name: 'gitlab', path: 'gitlab-org') }
  let(:projects) { table(:projects) }
  let(:approval_project_rules) { table(:approval_project_rules) }

  def create_project(id)
    projects.create(id: id, namespace_id: namespace.id)
  end

  def create_rule(id, project_id:, rule_type:)
    approval_project_rules.create(
      id: id, project_id: project_id, rule_type: rule_type,
      approvals_required: 3, name: ApprovalRuleLike::ALL_MEMBERS)
  end

  before do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)

    create_project(1)
    create_rule(1, project_id: 1, rule_type: 3)

    create_project(2)
    create_rule(2, project_id: 2, rule_type: 4)

    create_project(3)
    create_rule(3, project_id: 3, rule_type: 3)
    create_rule(4, project_id: 3, rule_type: 4)

    create_project(4)
    create_rule(5, project_id: 4, rule_type: 3)
    create_rule(6, project_id: 4, rule_type: 4)

    create_project(5)
    create_rule(7, project_id: 5, rule_type: 4)
  end

  it 'sets all rule types to 3 and removes duplicates' do
    expect(approval_project_rules.where(rule_type: 4).count).to eq(4)
    expect(approval_project_rules.where(rule_type: 3).count).to eq(3)

    expect { migrate! }.to change(approval_project_rules, :count).from(7).to(5)

    expect(approval_project_rules.where(rule_type: 4)).to eq([])

    rows = approval_project_rules.where(rule_type: 3).order(:id).map do |row|
      row.attributes.slice('id', 'project_id')
    end

    expect(rows).to eq([
      { "id" => 1, "project_id" => 1 },
      { "id" => 2, "project_id" => 2 },
      { "id" => 3, "project_id" => 3 },
      { "id" => 5, "project_id" => 4 },
      { "id" => 7, "project_id" => 5 }
    ])
  end
end
