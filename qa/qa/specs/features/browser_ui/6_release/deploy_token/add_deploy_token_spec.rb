# frozen_string_literal: true

module QA
  context 'Release', quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/213222', type: :flaky } do
    describe 'Deploy token creation' do
      it 'user adds a deploy token' do
        Flow::Login.formless_login

        deploy_token_name = 'deploy token name'
        one_week_from_now = Date.today + 7

        deploy_token = Resource::DeployToken.fabricate_via_browser_ui! do |resource|
          resource.name = deploy_token_name
          resource.expires_at = one_week_from_now
        end

        expect(deploy_token.username.length).to be > 0
        expect(deploy_token.password.length).to be > 0
      end
    end
  end
end
