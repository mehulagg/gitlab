# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/edit' do
  let(:project) { create(:project) }
  let(:user) { create(:admin) }

  before do
    assign(:project, project)

    allow(controller).to receive(:current_user).and_return(user)
    allow(view).to receive_messages(current_user: user,
                                    can?: true,
                                    current_application_settings: Gitlab::CurrentSettings.current_application_settings)
  end

  context 'status checks' do
    context 'feature enabled' do
      before do
        stub_feature_flags(ff_compliance_approval_gates: true)

        render
      end

      it 'shows the status checks area' do
        expect(rendered).to have_content('Status check')
      end
    end

    context 'feature disabled' do
      before do
        stub_feature_flags(ff_compliance_approval_gates: false)

        render
      end

      it 'hides the status checks area' do
        expect(rendered).not_to have_content('Status check')
      end
    end
  end
end
