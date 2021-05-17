# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuthorizedProjectUpdate::ProjectRecalculateWorker do
  let_it_be(:project) { create(:project) }

  it 'is labeled as high urgency' do
    expect(described_class.get_urgency).to eq(:high)
  end

  describe '#perform' do
    it 'calls AuthorizedProjectUpdate::ProjectRecalculateService' do
      expect_next_instance_of(AuthorizedProjectUpdate::ProjectRecalculateService, project) do |service|
        expect(service).to receive(:execute)
      end

      described_class.new.perform(project.id)
    end
  end
end
