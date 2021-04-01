# frozen_string_literal: true

require 'generator_helper'

RSpec.describe Gitlab::SnowplowEventDefinitionGenerator do
  let(:temp_dir) { Dir.mktmpdir }

  before do
    stub_const("#{described_class}::TOP_LEVEL_DIR", temp_dir)
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe 'Creating event definition file' do
    let(:sample_event) do
      file = fixture_file("lib/generators/gitlab/snowplow_event_definition_generator/sample_event.yml")
      ::Gitlab::Config::Loader::Yaml.new(file).load_raw!
    end

    it 'creates event definition file using the template' do
      described_class.new([], { 'category' => 'Groups::EmailCampaignsController', 'action' => 'click' }).invoke_all

      event_definition_path = Dir.glob(File.join(temp_dir, 'events/*_Groups::EmailCampaignsController_click.yml')).first

      expect(YAML.safe_load(File.read(event_definition_path))).to eq(sample_event)
    end
  end
end
