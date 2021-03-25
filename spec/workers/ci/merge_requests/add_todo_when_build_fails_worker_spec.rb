# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::MergeRequests::AddTodoWhenBuildFailsWorker do
  describe '#perform' do
    let_it_be(:project) { create(:project) }
    let_it_be(:job) { create(:ci_build, project: project) }
    let(:job_id) { job.id }
    
    subject { described_class.new.perform(job_id) }
    
    it 'does nothing' do
      expect(::MergeRequests::AddTodoWhenBuildFailsService).not_to receive(:new)
      
      subject
    end

    context 'when ci build failed' do
      before do
        job.update!(status: :failed)
      end

      it 'adds a todo' do
        service = double()
        expect(::MergeRequests::AddTodoWhenBuildFailsService).to receive(:new).with(project, nil).and_return(service)
        expect(service).to receive(:execute).with(job)

        described_class.new.perform(job_id)
      end
    end
  end
end
