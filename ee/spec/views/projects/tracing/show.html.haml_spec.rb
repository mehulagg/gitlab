# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/tracings/show' do
  let(:project) { create(:project, :repository) }
  let(:error_tracking_setting) { create(:project_error_tracking_setting, project: project) }

  before do
    assign(:project, project)
    assign(:repository, project.repository)
    allow(view).to receive(:current_ref).and_return('master')
    allow(view).to receive(:error_tracking_setting).and_return(error_tracking_setting)
    allow(view).to receive(:incident_management_available?) { false }
    stub_licensed_features(tracing: true)
  end

  context 'with project.tracing_external_url' do
    let(:tracing_url) { 'https://tracing.url' }
    let(:tracing_setting) { create(:project_tracing_setting, project: project, external_url: tracing_url) }

    before do
      allow(view).to receive(:can?).and_return(true)
      allow(view).to receive(:tracing_setting).and_return(tracing_setting)
    end

    it 'renders iframe' do
      render

      expect(rendered).to match(/iframe/)
    end

    context 'with malicious external_url' do
      let(:malicious_tracing_url) { "https://replaceme.com/'><script>alert(document.cookie)</script>" }
      let(:cleaned_url) { "https://replaceme.com/'&gt;" }

      before do
        tracing_setting.update_column(:external_url, malicious_tracing_url)
      end

      it 'sanitizes external_url' do
        render

        expect(tracing_setting.external_url).to eq(malicious_tracing_url)
        expect(rendered).to have_xpath("//iframe[@src=\"#{cleaned_url}\"]")
      end
    end
  end

  context 'without project.tracing_external_url' do
    before do
      allow(view).to receive(:can?).and_return(true)
    end

    it 'renders empty state' do
      render

      expect(rendered).to have_link('Add Jaeger URL')
      expect(rendered).not_to match(/iframe/)
    end
  end
end
