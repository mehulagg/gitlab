# frozen_string_literal: true

RSpec.shared_context 'project with approval rules' do
  let(:approver) { create(:user) }
  let(:author) { create(:user) }
  let(:project) { create(:project, :public, :repository) }

  before do
    stub_licensed_features(multiple_approval_rules: true)

    [approver, author].each do |member|
      project.add_maintainer(member)
    end
  end

  let!(:regular_rules) do
    Array.new(3) do |i|
      create(:approval_project_rule, project: project, users: [approver], name: "Regular Rule #{i}")
    end
  end
end
