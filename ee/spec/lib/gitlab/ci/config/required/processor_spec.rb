# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Config::Required::Processor do
  subject { described_class.new(config).perform }

  let(:config) { { image: 'ruby:2.5.3' } }

  context 'when feature is available' do
    before do
      stub_licensed_features(required_template_inclusion: true)

      allow(Gitlab::CurrentSettings.current_application_settings).to receive(:required_template_name) { required_template_name }
    end

    context 'when template is set' do
      context 'when template can not be found' do
        let(:required_template_name) { 'invalid_template_name' }

        it 'raises an error' do
          expect { subject }.to raise_error(Gitlab::Ci::Config::Required::Processor::RequiredError)
        end
      end

      context 'when template can be found' do
        let(:required_template_name) { 'Android' }

        it 'merges the template content with the config' do
          expect(subject).to include(image: 'openjdk:8-jdk')
        end
      end
    end

    context 'when template is not set' do
      let(:required_template_name) { nil }

      it 'returns the unmodified config' do
        expect(subject).to eq(config)
      end
    end
  end

  context 'when feature is not available' do
    before do
      stub_licensed_features(required_template_inclusion: false)
    end

    it 'returns the unmodified config' do
      expect(subject).to eq(config)
    end
  end
end
