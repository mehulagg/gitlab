# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Static Site Editor' do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, :repository) }

  let(:sse_path) { project_show_sse_path(project, 'master/README.md') }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  context "when no config file is present" do
    before do
      visit sse_path
    end

    it 'renders Static Site Editor page with all generated config values and default config file values' do
      # assert generated config values are present
      expect(page).to have_css('#static-site-editor[data-base-url="/namespace1/project1/-/sse/master%2FREADME.md"]')
      expect(page).to have_css('#static-site-editor[data-branch="master"]')
      expect(page).to have_css('#static-site-editor[data-commit-id]')
      expect(page).to have_css('#static-site-editor[data-is-supported-content="true"]')
      expect(page).to have_css('#static-site-editor[data-merge-requests-illustration-path^="/assets/illustrations/merge_requests-"]')
      expect(page).to have_css('#static-site-editor[data-namespace="namespace1"]')
      expect(page).to have_css('#static-site-editor[data-project="project1"]')
      expect(page).to have_css('#static-site-editor[data-project-id="1"]')

      # assert default config file values are present
      expect(page).to have_css('#static-site-editor[data-static-site-generator="middleman"]')
    end
  end

  context "when a config file is present" do
    let(:config_file_yml) do
      # NOTE: There isn't currently any support for a non-default config value, but this can be
      #       manually tested by temporarily adding an additional supported valid value in
      #       lib/gitlab/static_site_editor/config/file_config/entry/static_site_generator.rb.
      #       As soon as there is a real non-default value supported by the config file,
      #       this test can be updated to include it.
      <<-EOS
        static_site_generator: middleman
      EOS
    end

    before do
      allow_any_instance_of(Repository).to receive(:blob_data_at).and_return(config_file_yml)

      visit sse_path
    end

    it 'renders Static Site Editor page values read from config file' do
      # assert user-specified config file values are present
      expect(page).to have_css('#static-site-editor[data-static-site-generator="middleman"]')
    end
  end
end
