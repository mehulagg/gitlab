# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuthorizedProjectUpdate::ProjectRecalculateWorker do
  let_it_be(:project) { create(:project) }

  subject(:worker) { described_class.new }

  it 'is labeled as high urgency' do
    expect(described_class.get_urgency).to eq(:high)
  end

  include_examples 'an idempotent worker' do
    let(:job_args) { project.id }

    it 'does not change authorizations when run twice' do
      user = create(:user)
      project.add_developer(user)

      user.project_authorizations.delete_all

      expect { worker.perform(project.id) }.to change { project.project_authorizations.reload.size }.by(1)
      expect { worker.perform(project.id) }.not_to change { project.project_authorizations.reload.size }
    end
  end

  describe '#perform' do
    it 'calls AuthorizedProjectUpdate::ProjectRecalculateService' do
      expect_next_instance_of(AuthorizedProjectUpdate::ProjectRecalculateService, project) do |service|
        expect(service).to receive(:execute)
      end

      worker.perform(project.id)
    end
  end
end
