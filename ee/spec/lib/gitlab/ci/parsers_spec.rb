# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers do
  using RSpec::Parameterized::TableSyntax

  describe '.fabricate!' do
    where(:file_type, :args, :expected_parser) do
      :license_management  | []             | ::Gitlab::Ci::Parsers::LicenseCompliance::LicenseScanning
      :license_scanning    | []             | ::Gitlab::Ci::Parsers::LicenseCompliance::LicenseScanning
      :dependency_scanning | ['{}', double] | ::Gitlab::Ci::Parsers::Security::DependencyScanning
      :container_scanning  | ['{}', double] | ::Gitlab::Ci::Parsers::Security::ContainerScanning
      :dast                | ['{}', double] | ::Gitlab::Ci::Parsers::Security::Dast
      :sast                | ['{}', double] | ::Gitlab::Ci::Parsers::Security::Sast
      :api_fuzzing         | ['{}', double] | ::Gitlab::Ci::Parsers::Security::Dast
      :coverage_fuzzing    | ['{}', double] | ::Gitlab::Ci::Parsers::Security::CoverageFuzzing
      :secret_detection    | ['{}', double] | ::Gitlab::Ci::Parsers::Security::SecretDetection
      :metrics             | []             | ::Gitlab::Ci::Parsers::Metrics::Generic
      :requirements        | []             | ::Gitlab::Ci::Parsers::RequirementsManagement::Requirement
    end

    with_them do
      subject { described_class.fabricate!(file_type, *args) }

      it { is_expected.to be_an_instance_of(expected_parser) }
    end
  end
end
