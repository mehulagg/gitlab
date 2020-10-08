# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Mutation'] do
  describe 'deprecated mutations' do
    using RSpec::Parameterized::TableSyntax

    where(:field_name, :reason, :milestone) do
      'RunDastScan' | 'Use DastOnDemandScanCreate' | '13.4'
    end

    with_them do
      let(:field) { get_field(field_name) }
      let(:deprecation_reason) { "#{reason}. Deprecated in #{milestone}" }

      it { expect(field).to be_present }
      it { expect(field.deprecation_reason).to eq(deprecation_reason) }
    end
  end

  def get_field(name)
    described_class.fields[GraphqlHelpers.fieldnamerize(name.camelize)]
  end
end
