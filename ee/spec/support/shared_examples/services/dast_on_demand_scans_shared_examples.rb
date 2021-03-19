# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'it delegates scan creation to another service' do
  it 'calls DastOnDemandScans::CreateService' do
    expect(DastOnDemandScans::CreateService).to receive(:new).with(hash_including(params: delegated_params)).and_call_original

    subject
  end
end
