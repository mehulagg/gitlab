# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'Project access tokens' do
      it 'allows a user to create and use a project access token', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1705' do
        QA::Resource::ProjectAccessToken.fabricate_via_browser_ui!
      end
    end
  end
end
