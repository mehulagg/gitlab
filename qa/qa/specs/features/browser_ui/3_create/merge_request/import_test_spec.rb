# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Test Import' do
      before do
        Flow::Login.sign_in
      end
      
      it 'testing' do
        Resource::MergeRequest.fabricate_via_browser_ui!
      end
    end
  end
end
