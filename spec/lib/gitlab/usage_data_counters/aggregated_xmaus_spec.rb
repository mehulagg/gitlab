# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'aggregated xMAUs' do
  YAML.load_file(Rails.root.join('lib/gitlab/usage_data_counters/aggregated_xmaus.yml')).map(&:with_indifferent_access).each do |xmau|
    context "for #{xmau[:name]} xMAU" do
      it "is not calcualted with not existing AMAU" do
        xmau[:aggregated_metrics].each do |amau|
          expect(Gitlab::UsageDataCounters::HLLRedisCounter.known_event?(amau)).to be true
        end
      end

      it "has expected structure" do
        expect(xmau.keys).to match_array(%i[name aggregation_operator aggregated_metrics])
      end
    end
  end
end
