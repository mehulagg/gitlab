# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::IssueLinkPolicy do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }
  let(:vulnerability) { create(:vulnerability, project: project) }
  let(:issue) { create(:issue, project: project) }
  let(:vulnerability_issue_link) { build(:vulnerabilities_issue_link, vulnerability: vulnerability, issue: issue) }

  subject { described_class.new(user, vulnerability_issue_link) }

  context 'with a user authorized to admin vulnerability-issue links' do
    before do
      stub_licensed_features(security_dashboard: true)

      project.add_developer(user)
    end

    context 'with missing vulnerability' do
      let(:vulnerability) { nil }
      let(:issue) { create(:issue) }

      it { is_expected.to be_disallowed(:admin_vulnerability_issue_link) }
    end

    context 'when issue and link belong to the same project' do
      it { is_expected.to be_allowed(:admin_vulnerability_issue_link) }
    end

    context "when issue and link don't belong to the same project" do
      let(:issue) { create(:issue) }

      it { is_expected.to be_allowed(:admin_vulnerability_issue_link) }
    end
  end
end
