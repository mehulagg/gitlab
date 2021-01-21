# frozen_string_literal: true

require_relative 'danger_spec_helper'

require_relative '../../../tooling/danger/feature_flag'

RSpec.describe Tooling::Danger::FeatureFlag do
  include DangerSpecHelper

  let(:added_files) { nil }
  let(:fake_git) { double('fake-git', added_files: added_files) }

  let(:mr_labels) { nil }
  let(:mr_json) { nil }
  let(:fake_gitlab) { double('fake-gitlab', mr_labels: mr_labels, mr_json: mr_json) }

  let(:changes_by_category) { nil }
  let(:sanitize_mr_title) { nil }
  let(:ee?) { false }
  let(:fake_helper) { double('fake-helper', changes_by_category: changes_by_category, sanitize_mr_title: sanitize_mr_title, ee?: ee?) }

  let(:fake_danger) { new_fake_danger.include(described_class) }

  subject(:feature_flag) { fake_danger.new(git: fake_git, gitlab: fake_gitlab, helper: fake_helper) }

  describe '#found' do
    subject { feature_flag.found }

    context 'added files contain a feature_flag' do
      [
        'config/feature_flags/development/entry.yml',
        'ee/config/feature_flags/ops/entry.yml'
      ].each do |file_path|
        let(:added_files) { [file_path] }

        it { is_expected.to be_truthy }
      end
    end

    context 'added files do not contain a feature_flag' do
      [
        'app/models/model.rb',
        'app/assets/javascripts/file.js'
      ].each do |file_path|
        let(:added_files) { [file_path] }
        it { is_expected.to eq(nil) }
      end
    end
  end

  describe described_class::Found do
    let(:feature_flag_path) { 'config/feature_flags/development/entry.yml' }
    let(:group) { 'group::source code' }
    let(:raw_yaml) do
      YAML.dump('group' => group)
    end

    subject(:found) { described_class.new(feature_flag_path) }

    before do
      expect(File).to receive(:read).with(feature_flag_path).and_return(raw_yaml)
    end

    describe '#raw' do
      it 'returns the raw YAML' do
        expect(found.raw).to eq(raw_yaml)
      end
    end

    describe '#group' do
      it 'returns the group found in the YAML' do
        expect(found.group).to eq(group)
      end
    end

    describe '#group_match_mr_label?' do
      subject(:result) { found.group_match_mr_label?(mr_group_label) }

      context 'when MR labels match FF group' do
        let(:mr_group_label) { 'group::source code' }

        specify { expect(result).to eq(true) }
      end

      context 'when MR labels does not match FF group' do
        let(:mr_group_label) { 'group::access' }

        specify { expect(result).to eq(false) }
      end

      context 'when group is nil' do
        let(:group) { nil }

        context 'and MR has no group label' do
          let(:mr_group_label) { nil }

          specify { expect(result).to eq(true) }
        end

        context 'and MR has a group label' do
          let(:mr_group_label) { 'group::source code' }

          specify { expect(result).to eq(false) }
        end
      end
    end
  end
end
