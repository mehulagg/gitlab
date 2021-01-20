# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::DateTime do
  describe '.to_utc_date' do
    context 'column name is a String' do
      it 'returns Arel::Node::NamedFunction' do
        expect(described_class.to_utc_date('column')).to be_an_instance_of(Arel::Nodes::NamedFunction)
      end

      it 'returns object that translates to correct SQL fragment' do
        expect(described_class.to_utc_date('column').to_sql).to eq "DATE(TIMEZONE('UTC', column))"
      end
    end

    context 'column name is an Arel attribute' do
      let(:column) { Arel::Table.new('test')['column'] }

      it 'returns Arel::Node::NamedFunction' do
        expect(described_class.to_utc_date(column)).to be_an_instance_of(Arel::Nodes::NamedFunction)
      end

      it 'returns object that translates to correct SQL fragment' do
        expect(described_class.to_utc_date(column).to_sql).to eq "DATE(TIMEZONE('UTC', \"test\".\"column\"))"
      end
    end
  end
end
