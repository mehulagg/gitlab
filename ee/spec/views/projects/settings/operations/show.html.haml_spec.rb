# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/settings/operations/show' do
  let_it_be(:project, refind: true) { create(:project, :repository) }
  let_it_be(:error_tracking_setting) { create(:project_error_tracking_setting, project: project) }

  let(:operations_show_locals) do
    {
      prometheus_service: project.find_or_initialize_service('prometheus'),
      alerts_service: project.find_or_initialize_service('alerts')
    }
  end

  before do
    assign(:project, project)
    assign(:repository, project.repository)
    allow(view).to receive(:current_ref).and_return('master')
    allow(view).to receive(:error_tracking_setting).and_return(error_tracking_setting)
    allow(view).to receive(:incident_management_available?) { false }
    stub_licensed_features(tracing: true)
  end

  describe 'Operations > Tracing' do
    context 'with project.tracing_external_url' do
      let(:tracing_url) { 'https://tracing.url' }
      let(:tracing_setting) { create(:project_tracing_setting, project: project, external_url: tracing_url) }

      before do
        allow(view).to receive(:can?).and_return(true)
        allow(view).to receive(:tracing_setting).and_return(tracing_setting)
      end

      it 'links to project.tracing_external_url' do
        render template: 'projects/settings/operations/show', locals: operations_show_locals

        expect(rendered).to have_link('Tracing', href: tracing_url)
      end

      context 'with malicious external_url' do
        let(:malicious_tracing_url) { "https://replaceme.com/'><script>alert(document.cookie)</script>" }
        let(:cleaned_url) { "https://replaceme.com/'>" }

        before do
          tracing_setting.update_column(:external_url, malicious_tracing_url)
        end

        it 'sanitizes external_url' do
          render template: 'projects/settings/operations/show', locals: operations_show_locals

          expect(tracing_setting.external_url).to eq(malicious_tracing_url)
          expect(rendered).to have_link('Tracing', href: cleaned_url)
        end
      end
    end

    context 'without project.tracing_external_url' do
      let(:tracing_setting) { build(:project_tracing_setting, project: project) }

      before do
        allow(view).to receive(:can?).and_return(true)
        allow(view).to receive(:tracing_setting).and_return(tracing_setting)

        tracing_setting.external_url = nil
      end

      it 'links to Tracing page' do
        render template: 'projects/settings/operations/show', locals: operations_show_locals

        expect(rendered).to have_link('Tracing', href: project_tracing_path(project))
      end
    end
  end
end
