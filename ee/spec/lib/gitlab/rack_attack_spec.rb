# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RackAttack, :aggregate_failures do
  describe '.configure' do
    let(:fake_rack_attack) { class_double("Rack::Attack") }
    let(:fake_rack_attack_request) { class_double("Rack::Attack::Request") }

    before do
      stub_const("Rack::Attack", fake_rack_attack)
      stub_const("Rack::Attack::Request", fake_rack_attack_request)

      allow(fake_rack_attack).to receive(:throttled_response=)
      allow(fake_rack_attack).to receive(:throttle)
      allow(fake_rack_attack).to receive(:track)
      allow(fake_rack_attack).to receive(:safelist)
      allow(fake_rack_attack).to receive(:blocklist)
    end

    it 'adds the incident management throttle' do
      described_class.configure(fake_rack_attack)

      expect(fake_rack_attack).to have_received(:throttle)
        .with('throttle_incident_management_notification_web', Gitlab::Throttle.authenticated_web_options)
    end
  end
end
