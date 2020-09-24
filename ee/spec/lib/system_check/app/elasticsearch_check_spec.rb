# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SystemCheck::App::ElasticsearchCheck do
  describe '#skip?' do
    context 'with elasticsearch disabled' do
      before do
        allow(Gitlab::CurrentSettings.current_application_settings).to receive(:elasticsearch_indexing?).and_return(false)
      end

      it 'returns true' do
        expect(described_class.new.skip?).to eq(true)
      end
    end

    context 'with elasticsearch enabled' do
      before do
        allow(Gitlab::CurrentSettings.current_application_settings).to receive(:elasticsearch_indexing?).and_return(true)
      end
      it 'returns false' do
        expect(described_class.new.skip?).to eq(false)
      end
    end
  end

  describe '#check?' do
    using RSpec::Parameterized::TableSyntax

    subject { described_class.new.check? }

    where(:version, :result) do
      '2.3.0' | false
      '5.3.1' | false
      '5.6.0' | false
      '5.6.6' | false
      '6.0.0' | true
      '6.4.2' | true
      '7.1.0' | true
      '7.5.1' | true
    end

    with_them do
      before do
        # `current_version` is memoized, so we must clear it out
        described_class.instance_variable_set(:@current_version, nil)
        allow(Gitlab::Elastic::Client).to receive(:build).and_return(double(info: { 'version' => { 'number' => version } }))
      end

      it { is_expected.to eq(result) }
    end
  end
end
