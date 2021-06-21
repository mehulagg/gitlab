# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NewProjectReadmeContentExperiment, :experiment do
  subject { described_class.new(namespace: project.namespace) }

  let(:project) { create(:project, name: 'Experimental', description: 'An experiment project') }

  it "renders the basic README" do
    expect(subject.run_with(project)).to eq(<<~MARKDOWN.strip)
      # Experimental

      An experiment project
    MARKDOWN
  end

  describe "the advanced variant" do
    let(:markdown) { subject.run_with(project, variant: :advanced) }

    before do
      allow(subject).to receive(:key_for).and_return('ABC123')
    end

    it "renders the project details in the README" do
      expect(markdown).to include(<<~MARKDOWN.strip)
        # Experimental

        An experiment project

        ## Getting started
      MARKDOWN
    end

    it "renders redirect urls" do
      initial_url = 'https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file'
      mounted_at = Gitlab::Experiment::Configuration.mount_at

      if mounted_at.nil?
        expect(markdown).to include(initial_url)
      else
        expect(markdown).to include("#{mounted_at}/#{subject.to_param}?#{initial_url}")
      end
    end
  end
end
