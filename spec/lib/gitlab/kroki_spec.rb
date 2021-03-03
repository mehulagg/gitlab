# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::Kroki do
  using RSpec::Parameterized::TableSyntax

  describe '.formats' do
    subject { described_class.formats(Gitlab::CurrentSettings) }

    context 'with no additional formats selected' do
      before do
        stub_application_setting(kroki_enabled: true, kroki_url: "http://localhost:8000")
      end

      it 'returns no block diagram formats' do
        expect(subject).not_to include(*described_class::BLOCKDIAG_FORMATS)
      end
    end

    where(:enabled_formats, :expected_formats) do
      'blockdiag'  | %w[actdiag blockdiag bytefield c4plantuml ditaa erd graphviz nomnoml nwdiag packetdiag plantuml rackdiag seqdiag svgbob umlet vega vegalite wavedrow]
      'bpmn'       | %w[bpmn bytefield c4plantuml ditaa erd graphviz nomnoml plantuml svgbob umlet vega vegalite wavedrow]
      'excalidraw' | %w[bytefield c4plantuml ditaa erd excalidraw graphviz nomnoml plantuml svgbob umlet vega vegalite wavedrow]
    end

    with_them do
      before do
        stub_application_setting(kroki_enabled: true, kroki_url: "http://localhost:8000", kroki_formats: { enabled_formats => true })
      end

      it 'returns the expected formats' do
        expect(subject).to eq(expected_formats)
      end
    end
  end
end
