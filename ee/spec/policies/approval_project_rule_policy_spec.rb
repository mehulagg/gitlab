# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalProjectRulePolicy do
  let(:project) { create(:project) }
  let!(:approval_rule) { create(:approval_project_rule, project: project) }

  def permissions(user, approval_rule)
    described_class.new(user, approval_rule)
  end

  context 'when user can admin project' do
    it 'allows updating approval rule' do
      expect(permissions(project.creator, approval_rule)).to be_allowed(:edit_approval_rule)
    end
  end

  context 'when user cannot admin project' do
    let(:user) { create(:user) }

    before do
      project.add_developer(user)
    end

    it 'disallow updating approval rule' do
      expect(permissions(user, approval_rule)).to be_disallowed(:edit_approval_rule)
    end
  end
end
