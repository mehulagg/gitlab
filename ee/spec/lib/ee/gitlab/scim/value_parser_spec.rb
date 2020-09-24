# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Scim::ValueParser do
  using RSpec::Parameterized::TableSyntax

  describe '#type_cast' do
    where(:input, :expected_output) do
      'True' | true
      'true' | true
      'False' | false
      'false' | false
      '"Quoted String"' | 'Quoted String'
      true | true
      false | false
      123 | 123
    end

    with_them do
      it do
        expect(described_class.new(input).type_cast).to eq expected_output
      end
    end
  end
end
