# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssueRebalancingWorker do
  describe '#perform' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, group: group) }
    let_it_be(:issue) { create(:issue, project: project) }

    shared_examples 'running the worker' do
      it 'runs an instance of IssueRebalancingService' do
        service = double(execute: nil)
        expect(IssueRebalancingService).to receive(:new).with(group).and_return(service)

        described_class.new.perform(*arguments)
      end

      it 'anticipates there being too many issues' do
        service = double
        allow(service).to receive(:execute) { raise IssueRebalancingService::TooManyIssues }
        expect(IssueRebalancingService).to receive(:new).with(group).and_return(service)
        expect(Gitlab::ErrorTracking).to receive(:log_exception).with(IssueRebalancingService::TooManyIssues, include(root_namespace_id: group.id))

        described_class.new.perform(*arguments)
      end

      it 'takes no action if the value is nil' do
        expect(IssueRebalancingService).not_to receive(:new)
        expect(Gitlab::ErrorTracking).not_to receive(:log_exception)

        described_class.new.perform # all arguments are nil
      end
    end

    shared_examples 'safely handles non-existent ids' do
      it 'anticipates the inability to find the issue' do
        expect(Gitlab::ErrorTracking).to receive(:log_exception).with(ArgumentError, include(project_id: arguments[1], root_namespace_id: arguments[2]))
        expect(IssueRebalancingService).not_to receive(:new)

        described_class.new.perform(*arguments)
      end
    end

    context 'without root_namespace param' do
      it_behaves_like 'running the worker' do
        let(:arguments) { [-1, project.id] }
      end

      it_behaves_like 'safely handles non-existent ids' do
        let(:arguments) { [nil, -1] }
      end
    end

    context 'with root_namespace param' do
      it_behaves_like 'running the worker' do
        let(:arguments) { [nil, nil, group.id] }
      end

      it_behaves_like 'safely handles non-existent ids' do
        let(:arguments) { [nil, nil, -1] }
      end
    end
  end

  it 'has the `until_executed` deduplicate strategy' do
    expect(described_class.get_deduplicate_strategy).to eq(:until_executed)
    expect(described_class.get_deduplication_options).to include({ including_scheduled: true })
  end
end
