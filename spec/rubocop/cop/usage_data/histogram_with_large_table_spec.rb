# frozen_string_literal: true

require 'fast_spec_helper'

require_relative '../../../../rubocop/cop/usage_data/histogram_with_large_table'

RSpec.describe RuboCop::Cop::UsageData::HistogramWithLargeTable do
  let(:large_tables) { %i[issues ci_builds] }
  let(:msg) { 'Use one of the count, distinct_count methods for counting on' }

  let(:config) do
    RuboCop::Config.new('Migration/UpdateLargeTable' => {
                          'HighTrafficTables' => large_tables
                        })
  end

  subject(:cop) { described_class.new(config) }

  context 'with large tables' do
    context 'when calling histogram(Issue)' do
      it 'does not register an offense' do
        expect_no_offenses('count(Issue, :project_id, buckets: 1..100)')
      end
    end

    context 'when calling histogram(::Ci::Build)' do
      it 'does not register an offense' do
        expect_offense(<<~CODE)
          histogram(::Ci::Build.active, buckets: 1..100)
          ^^^^^^^^^ #{msg} Ci::Build
        CODE
      end
    end

    context 'when calling histogram(Ci::Build.active)' do
      it 'does not register an offense' do
        expect_no_offenses('hist(Ci::Build.active, :project_id, buckets: 1..100)')
        expect_offense(<<~CODE)
          histogram(Ci::Build.active)
          ^^^^^^^^^ #{msg} Ci::Build
        CODE
      end
    end
  end

  context 'with non related class' do
    it 'does not register an offense' do
      expect_no_offenses('histogram(MergeRequest, buckets: 1..100)')
    end
  end
end
