# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::IssueSidebarBasicEntity do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:issue) { create(:issue, project: project, assignees: [user]) }
  let(:subject) { IssueSerializer.new(current_user: user, project: project) }

  context "When serializing" do
    context "with the cve_id_request_button feature flag enabled" do
      using RSpec::Parameterized::TableSyntax

      where(:is_gitlab_com, :is_public, :is_admin, :expected_value) do
        true  | true  | true  | true
        true  | false | true  | false
        true  | false | false | false
        false | false | true  | false
        false | false | false | false
      end
      with_them do
        before do
          allow(issue.project).to receive(:public?).and_return(is_public)
          issue.project.add_maintainer(user) if is_admin
          allow(Gitlab).to receive(:com?).and_return(is_gitlab_com)
          stub_feature_flags(cve_id_request_button: true)
        end

        it 'uses the value from request_cve_enabled_for_user when the feature flag is on' do
          data = subject.represent(issue, serializer: 'sidebar')
          expect(data[:request_cve_enabled_for_user]).to eq(expected_value)
        end
      end
    end

    context "with the cve_id_request_button feature flag disabled" do
      before do
        stub_feature_flags(cve_id_request_button: false)
      end

      it 'does not use the value from request_cve_enabled_for_user when the feature flag is off' do
        data = subject.represent(issue, serializer: 'sidebar')
        expect(data).not_to include(:request_cve_enabled_for_user)
      end
    end
  end
end
