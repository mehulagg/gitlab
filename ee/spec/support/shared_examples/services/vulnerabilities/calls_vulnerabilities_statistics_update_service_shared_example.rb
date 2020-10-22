# frozen_string_literal: true

RSpec.shared_examples 'calls Vulnerabilities::Statistics::UpdateService' do
  before do
    allow(Vulnerabilities::Statistics::UpdateService).to receive(:update_for)
  end

  it 'calls the service class' do
    subject

    expect(Vulnerabilities::Statistics::UpdateService).to have_received(:update_for)
  end
end
