# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebHooks::DestroyService do
  subject { described_class.new(user) }

  context 'with system hook' do
    let_it_be(:hook) { create(:system_hook, url: "http://example.com") }
    let_it_be(:log) { create_list(:web_hook_log, 3, web_hook: hook) }

    context 'with admin' do
      let(:user) { create(:admin) }

      it 'destroys all hooks in batches' do
        stub_const("#{described_class}::BATCH_SIZE", 1)
        expect(subject).to receive(:destroy_batch!).exactly(4).times.and_call_original

        expect { subject.execute(hook) }
          .to change { SystemHook.count }.from(1).to(0)
          .and change { WebHookLog.count }.from(3).to(0)
      end
    end

    context 'with regular user' do
      let(:user) { create(:user) }

      it 'raises an error' do
        expect { subject.execute(hook) }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end

  context 'with project hook' do
    let_it_be(:project) { create(:project) }
    let_it_be(:hook) { create(:project_hook, project: project) }
    let_it_be(:log) { create_list(:web_hook_log, 3, web_hook: hook) }

    context 'with project maintainer' do
      let(:user) { create(:user) }

      before do
        project.add_maintainer(user)
      end

      it 'destroys all hooks in batches' do
        stub_const("#{described_class}::BATCH_SIZE", 1)
        expect(subject).to receive(:destroy_batch!).exactly(4).times.and_call_original

        expect { subject.execute(hook) }
          .to change { WebHook.count }.from(1).to(0)
          .and change { WebHookLog.count }.from(3).to(0)
      end
    end

    context 'with project reporter' do
      let(:user) { create(:user) }

      before do
        project.add_reporter(user)
      end

      it 'raises an error' do
        expect { subject.execute(hook) }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end

    context 'with project reporter' do
      let(:user) { create(:user) }

      it 'raises an error' do
        expect { subject.execute(hook) }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end
