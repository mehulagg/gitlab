# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Minutes::UpdateProjectAndNamespaceUsageWorker do
  let(:worker) { described_class.new }
  let(:consumption) { 100 }
  let(:project) { create(:project) }
  let(:namespace) { create(:namespace) }

  describe '#perform' do
    it 'executes UpdateProjectAndNamespaceUsageService' do
      service_instance = double()
      expect(::Ci::Minutes::UpdateProjectAndNamespaceUsageService).to receive(:new).with(project, namespace).and_return(service_instance)
      expect(service_instance).to receive(:execute).with(consumption)

      described_class.new.perform(consumption, project.id, namespace.id)
    end
  end
end
