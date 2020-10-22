# frozen_string_literal: true

RSpec.shared_context 'status page enabled' do
  before do
    project.add_maintainer(user)

    stub_licensed_features(status_page: true)

    unless project.status_page_setting
      create(:status_page_setting, :enabled, project: project)
      project.reload
    end
  end
end

RSpec.shared_context 'stub status page enabled' do
  let(:status_page_setting_enabled) { true }
  let(:status_page_setting) do
    instance_double(
      StatusPage::ProjectSetting,
      enabled?: status_page_setting_enabled,
      storage_client: storage_client
    )
  end

  before do
    stub_licensed_features(status_page: true)
    allow(project).to receive(:status_page_setting)
    .and_return(status_page_setting)
  end
end
