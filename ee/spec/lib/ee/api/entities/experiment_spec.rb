# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Entities::Experiment do
  let(:experiment) { Feature::Definition.get(:null_hypothesis) }
  let(:entity) { described_class.new(experiment) }

  subject { entity.as_json }

  it do
    is_expected.to match(
      key: "null_hypothesis",
      state: :off,
      enabled: false,
      name: "null_hypothesis",
      introduced_by_url: "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/45840",
      rollout_issue_url: nil,
      milestone: "13.7",
      type: "experiment",
      group: "group::adoption",
      default_enabled: false
    )
  end

  it "understands conditional state and what that means" do
    Feature.enable_percentage_of_time(:null_hypothesis, 1)

    expect(subject).to include(
      state: :conditional,
      enabled: true
    )
  end

  it "understands state and what that means for if its enabled or not" do
    Feature.enable_percentage_of_time(:null_hypothesis, 100)

    expect(subject).to include(
      state: :on,
      enabled: true
    )
  end

  it "truncates the name since some experiments include extra data in their feature flag name" do
    experiment.attributes[:name] = 'foo_experiment_percentage'

    expect(subject).to include(
      key: 'foo'
    )
  end
end
