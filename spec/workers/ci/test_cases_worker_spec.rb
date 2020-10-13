# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::TestCasesWorker do
  subject(:perform_task) { described_class.new.perform(build_id) }

  context 'when build exists' do
    let(:build) { create(:ci_build) }
    let(:build_id) { build.id }

    it 'calls test cases service' do
      expect_next_instance_of(Ci::TestCasesService) do |service|
        expect(service).to receive(:execute)
      end

      perform_task
    end
  end

  context 'when build does not exist' do
    let(:build_id) { -1 }

    it 'does not call test cases service' do
      expect(Ci::TestCasesService).not_to receive(:new)

      perform_task
    end
  end
end
