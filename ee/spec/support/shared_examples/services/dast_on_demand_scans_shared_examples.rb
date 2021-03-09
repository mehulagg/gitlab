# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'it delegates scan creation to another service' do
  it 'calls DastOnDemandScans::CreateService' do
    expect(DastOnDemandScans::CreateService).to receive(:new).with(hash_including(params: delegated_params)).and_call_original

    subject
  end
end

RSpec.shared_examples 'a mutation that checks branch permissions' do
  context 'when the user does not have access to the branch' do
    before do
      create(:protected_branch, project: project, name: branch_name)
    end

    it 'communicates failure' do
      expect(subject[:errors][0]).to include("You do not have sufficient permission to run a pipeline on '#{branch_name}'")
    end
  end
end
