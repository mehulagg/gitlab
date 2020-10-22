# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::CIDR do
  using RSpec::Parameterized::TableSyntax

  context 'validation' do
    it 'raises an exception when an octet is invalid' do
      expect { described_class.new("192.1.1.257") }.to raise_error(described_class::ValidationError)
    end

    it 'raises an exception when a bitmask is invalid' do
      expect { described_class.new("192.1.1.0/34") }.to raise_error(described_class::ValidationError)
    end

    it 'raises an exception when one IP from a set is invalid' do
      expect { described_class.new("192.1.1.257, 192.1.1.1") }.to raise_error(described_class::ValidationError)
    end
  end

  context 'matching' do
    where(:values, :ip, :match) do
      "192.1.1.1"                  | "192.1.1.1"     | true
      "192.1.1.1, 192.1.2.1"       | "192.1.2.1"     | true
      "192.1.1.0/24"               | "192.1.1.223"   | true
      "192.1.0.0/16"               | "192.1.223.223" | true
      "192.1.0.0/16, 192.1.2.0/24" | "192.1.2.223"   | true
      "192.1.0.0/16"               | "192.2.1.1"     | false
      "192.1.0.1"                  | "192.2.1.1"     | false
    end

    with_them do
      specify do
        expect(described_class.new(values).match?(ip)).to eq(match)
      end
    end
  end
end
