# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RackAttack::UserAllowlist do
  using RSpec::Parameterized::TableSyntax

  subject { described_class.new(input) }

  where(:input, :empty, :elements) do
    nil | true | []
    '' | true | []
    '123' | false | [123]
    '123,456' | false | [123, 456]
    '123,foobar,456,' | false | [123, 456]
  end

  with_them do
    it 'responds to empty? correctly' do
      expect(subject.empty?).to eq(empty)
    end

    it 'responds to include? correctly' do
      elements.each { |elt| expect(subject).to include(elt) }
    end
  end
end
