# frozen_string_literal: true

module QA
  context 'Release' do
    describe 'Deploy key creation' do
      it 'user adds a deploy key' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        key = Runtime::Key::RSA.new
        deploy_key_title = 'deploy key title'
        deploy_key_value = key.public_key

        deploy_key = Resource::DeployKey.fabricate! do |resource|
          resource.title = deploy_key_title
          resource.key = deploy_key_value
        end

        expect(deploy_key.fingerprint).to eq(key.fingerprint)
      end
    end
  end
end
