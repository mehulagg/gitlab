# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Mutation'] do
  describe 'aliased deprecated mutations' do
    using RSpec::Parameterized::TableSyntax

    where(:alias_name, :canonical_name) do
      'DismissVulnerability' | 'VulnerabilityDismiss'
      'RevertVulnerabilityToDetected' | 'VulnerabilityRevertToDetected'
    end

    with_them do
      let(:alias_field) { get_field(alias_name) }
      let(:canonical_field) { get_field(canonical_name) }

      it { expect(alias_field).to be_present }
      it { expect(canonical_field).to be_present }
      it { expect(alias_field.deprecation_reason).to be_present }
      it { expect(canonical_field.deprecation_reason).not_to be_present }
      it { expect(alias_field.resolver.fields).to eq(canonical_field.resolver.fields) }
      it { expect(alias_field.resolver.arguments).to eq(canonical_field.resolver.arguments) }
    end
  end

  def get_field(name)
    described_class.fields[GraphqlHelpers.fieldnamerize(name.camelize)]
  end
end
