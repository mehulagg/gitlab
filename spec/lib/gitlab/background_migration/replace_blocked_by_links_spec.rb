# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::ReplaceBlockedByLinks, schema: 20201015073808 do
  let(:namespace) { table(:namespaces).create(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { table(:projects).create(namespace_id: namespace.id, name: 'gitlab') }
  let(:issue1) { table(:issues).create!(project_id: project.id, title: 'a') }
  let(:issue2) { table(:issues).create!(project_id: project.id, title: 'b') }
  let(:issue3) { table(:issues).create!(project_id: project.id, title: 'c') }
  let!(:blocks_link) { table(:issue_links).create!(source_id: issue1.id, target_id: issue2.id, link_type: 1) }
  let!(:bidirectional_link) { table(:issue_links).create!(source_id: issue2.id, target_id: issue1.id, link_type: 2) }
  let!(:blocked_link) { table(:issue_links).create!(source_id: issue1.id, target_id: issue3.id, link_type: 2) }

  subject { described_class.new.perform(IssueLink.minimum(:id), IssueLink.maximum(:id)) }

  it 'deletes issue links where opposite relation already exists' do
    expect { subject }.to change { IssueLink.count }.by(-1)
  end

  it 'ignores issue links other than blocked_by' do
    subject

    expect(blocks_link.reload.link_type).to eq(1)
  end

  it 'updates blocked_by issues' do
    subject

    expect(blocked_link.reload.link_type).to eq(1)
    expect(blocked_link.reload.source_id).to eq(issue3.id)
    expect(blocked_link.reload.target_id).to eq(issue1.id)
  end
end
