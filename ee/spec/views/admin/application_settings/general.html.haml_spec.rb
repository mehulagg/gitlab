# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/application_settings/general.html.haml' do
  let_it_be(:user) { create(:admin) }
  let_it_be(:app_settings) { build(:application_setting) }

  subject { rendered }

  before do
    assign(:application_setting, app_settings)
    allow(view).to receive(:current_user).and_return(user)
  end

  describe 'maintenance mode' do
    let(:maintenance_mode_flag) { true }
    let(:license_allows) { true }

    before do
      stub_feature_flags(maintenance_mode: maintenance_mode_flag)
      allow(Gitlab::Geo).to receive(:license_allows?).and_return(license_allows)

      render
    end

    context 'when license does not allow' do
      let(:license_allows) { false }

      it 'does not show the Maintenance mode section' do
        expect(rendered).not_to have_css('#js-maintenance-mode-toggle')
      end
    end

    context 'when license allows' do
      it 'shows the Maintenance mode section' do
        expect(rendered).to have_css('#js-maintenance-mode-toggle')
      end
    end
  end
end
