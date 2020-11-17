# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::ProcessRequirementsReportsWorker do
  describe '#perform' do
    context 'build exists' do
      let(:build) { create(:ci_build) }

      it 'processes requirements reports' do
        service_double = instance_double(RequirementsManagement::ProcessTestReportsService, execute: true)
        expect(RequirementsManagement::ProcessTestReportsService).to receive(:new).and_return(service_double)

        described_class.new.perform(build.id)
      end
    end

    context 'build does not exist' do
      it 'does not store requirements reports' do
        expect(RequirementsManagement::ProcessTestReportsService).not_to receive(:new)

        described_class.new.perform(non_existing_record_id)
      end
    end
  end
end
