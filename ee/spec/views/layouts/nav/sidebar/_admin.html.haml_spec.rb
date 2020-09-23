# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/nav/sidebar/_admin' do
  context 'on settings' do
    before do
      stub_licensed_features(custom_file_templates: custom_file_templates)

      render
    end

    context 'license with custom_file_templates feature' do
      let(:custom_file_templates) { true }

      it 'includes Templates link' do
        expect(rendered).to have_link('Templates', href: '/admin/application_settings/templates')
      end
    end

    context 'license without custom_file_templates feature' do
      let(:custom_file_templates) { false }

      it 'does not include Templates link' do
        expect(rendered).not_to have_link('Templates', href: '/admin/application_settings/templates')
      end
    end
  end
end
