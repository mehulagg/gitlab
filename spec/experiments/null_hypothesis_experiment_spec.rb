# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NullHypothesisExperiment, :experiment do
  let(:project) { create(:project) }

  describe "#flipper_id" do
    subject { experiment(:null_hypothesis, project: project) }

    it "proxies to the project flipper_id" do
      expect(subject.flipper_id).to eq project.flipper_id
    end

    it "falls back to the default behavior when project is nil" do
      expect(experiment(:null_hypothesis).flipper_id).to eq "Experiment;null_hypothesis:#{subject.signature[:key]}"
    end

    it "raises an exception when the project id is nil" do
      # This is the default gitlab-experiment behavior and is worth noting.
      expect { experiment(:null_hypothesis, project: Project.new).flipper_id }.to raise_error(
        URI::GID::MissingModelIdError
      )
    end
  end

  describe "integration with a simulated chatops command session" do
    let(:variants) do
      lambda do |e|
        e.use { }
        e.try { }
      end
    end

    before do
      allow(Gitlab).to receive(:dev_env_or_com?).and_return(true)
    end

    it "allows adding projects to an experiment using existing chatops commands" do
      subject = experiment(:null_hypothesis, project: project, &variants)

      expect(subject).not_to be_enabled

      # /chatops run feature set --project=[project] null_hypothesis true
      Feature.enable(subject.name, project)

      # It's worth noting that the above command changes the state of the
      # feature flag from :off to :conditional. The experiment is considered
      # "running" at this point, and events would start being tracking. Every
      # project would be assigned the control except for the one above.
      #
      # This may not be an understood side effect of just adding a project to
      # a currently disabled experiment, and want to call that out as one of
      # the primary concerns we've surfaced in discussions.

      subject = experiment(:null_hypothesis, project: project, &variants)

      expect(subject).to be_enabled
      expect(subject.variant.name).to eq('candidate')
    end
  end
end
