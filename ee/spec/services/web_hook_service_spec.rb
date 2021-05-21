# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebHookService do
  let_it_be(:project) { create(:project) }
  let_it_be_with_reload(:project_hook) { create(:project_hook, project: project) }

  let(:service_instance) { described_class.new(project_hook, {}, :push_hooks) }

  describe '#async_execute' do
    context 'when hook has custom context attributes' do
      it 'includes the subscription plan in the worker context' do
        expect(WebHookWorker).to receive(:perform_async) do
          expect(Gitlab::ApplicationContext.current).to include(
            'meta.subscription_plan' => 'default'
          )
        end

        service_instance.async_execute
      end

      context 'when the rate-limiting feature flag is disabled' do
        before do
          stub_feature_flags(web_hooks_rate_limit: false)
        end

        it 'does not include the subscription plan in the worker context' do
          expect(WebHookWorker).to receive(:perform_async) do
            expect(Gitlab::ApplicationContext.current).not_to include('meta.subscription_plan')
          end

          service_instance.async_execute
        end
      end
    end
  end
end
