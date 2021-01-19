# frozen_string_literal: true

RSpec.shared_examples 'can pick repository storage' do
  describe '.pick_repository_storage' do
    subject { described_class.pick_repository_storage }

    before do
      storages = {
        'default' => Gitlab::GitalyClient::StorageSettings.new('path' => 'tmp/tests/repositories'),
        'picked'  => Gitlab::GitalyClient::StorageSettings.new('path' => 'tmp/tests/repositories')
      }
      allow(Gitlab.config.repositories).to receive(:storages).and_return(storages)
    end

    it 'picks storage from ApplicationSetting' do
      expect(Gitlab::CurrentSettings).to receive(:pick_repository_storage).and_return('picked')

      expect(subject).to eq('picked')
    end

    it 'picks from the available storages based on weight', :request_store do
      stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      Gitlab::CurrentSettings.expire_current_application_settings
      Gitlab::CurrentSettings.current_application_settings

      settings = ApplicationSetting.last
      settings.repository_storages_weighted = { 'picked' => 100, 'default' => 0 }
      settings.save!

      expect(Gitlab::CurrentSettings.repository_storages_weighted).to eq({ 'default' => 100 })
      expect(subject).to eq('picked')
      expect(Gitlab::CurrentSettings.repository_storages_weighted).to eq({ 'default' => 0, 'picked' => 100 })
    end
  end
end
