# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StoreSecurityScansWorker do
  describe '#perform' do
    context 'build has security reports' do
      let(:build) { create(:ci_build, :dast) }

      before do
        create(:ee_ci_job_artifact, :dast, job: build)
      end

      it 'stores security scans' do
        expect(Security::StoreScansService).to receive(:new).with(build).and_call_original

        StoreSecurityScansWorker.new.perform(build.id)
      end
    end

    context 'build does not have security reports' do
      let(:build) { create(:ci_build) }

      it 'does not store security scans' do
        expect(Security::StoreScansService).not_to receive(:new)

        StoreSecurityScansWorker.new.perform(build.id)
      end
    end

    context 'build does not exist' do
      it 'does not store security scans' do
        expect(Security::StoreScansService).not_to receive(:new)

        StoreSecurityScansWorker.new.perform(666)
      end
    end
  end
end
