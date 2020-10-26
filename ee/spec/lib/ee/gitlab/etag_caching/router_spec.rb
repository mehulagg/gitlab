# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::EtagCaching::Router do
  it 'matches epic notes endpoint' do
    result = described_class.match(
      '/groups/my-group/and-subgroup/-/epics/1/notes'
    )

    expect(result).to be_present
    expect(result.name).to eq 'epic_notes'
  end

  it 'does not match invalid epic notes endpoint' do
    result = described_class.match(
      '/groups/my-group/-/and-subgroup/-/epics/1/notes'
    )

    expect(result).to be_blank
  end

  it 'has a valid feature category for every route', :aggregate_failures do
    feature_categories = YAML.load_file(Rails.root.join('config', 'feature_categories.yml')).to_set

    described_class::EE_ROUTES.each do |route|
      expect(feature_categories).to include(route.feature_category), "#{route.name} has a category of #{route.feature_category}, which is not valid"
    end
  end
end
