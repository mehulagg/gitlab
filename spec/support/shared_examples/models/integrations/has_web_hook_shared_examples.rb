# frozen_string_literal: true

RSpec.shared_examples Integrations::HasWebHook do
  describe 'callbacks' do
    it 'calls #compose_web_hook when enabled' do
      expect(integration).to receive(:compose_web_hook)

      integration.active = true
      integration.save!
    end

    it 'does not call #compose_web_hook when disabled' do
      expect(integration).not_to receive(:compose_web_hook)

      integration.active = false
      integration.save!
    end

    it 'does not call #compose_web_hook when validation fails' do
      expect(integration).not_to receive(:compose_web_hook)

      integration.active = true
      integration.project = nil
      expect(integration.save).to be(false)
    end
  end

  describe '#compose_web_hook' do
    it 'creates or updates a service hook' do
      expect do
        integration.compose_web_hook
      end.to change { integration.service_hook }.from(nil)

      expect(integration.service_hook.url).to eq(hook_url)

      integration.service_hook.update!(url: 'http://other.com')

      expect do
        integration.compose_web_hook
      end.to change { integration.service_hook.reload.url }.from('http://other.com').to(hook_url)
    end

    it 'raises an error if the service hook could not be saved' do
      integration.compose_web_hook
      integration.service_hook.integration = nil

      expect do
        integration.compose_web_hook
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
