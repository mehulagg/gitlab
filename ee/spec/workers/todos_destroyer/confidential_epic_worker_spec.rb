# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TodosDestroyer::ConfidentialEpicWorker do
  let(:service) { double }

  it 'calls the Todos::Destroy::ConfidentialEpicService with epic_id parameter' do
    expect(::Todos::Destroy::ConfidentialEpicService).to receive(:new).with(epic_id: 100).and_return(service)
    expect(service).to receive(:execute)

    described_class.new.perform(100)
  end
end
