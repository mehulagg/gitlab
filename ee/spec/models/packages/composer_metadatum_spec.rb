# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::ComposerMetadatum, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:package) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package) }

    describe '#name' do
      it { is_expected.to allow_value("ochorocho/gitlab-composer").for(:name) }
      it { is_expected.not_to allow_value("ochorocho?gitlab-composer").for(:name) }
      it { is_expected.not_to allow_value("ochorocho(gitlab-composer)").for(:name) }
    end

    describe '#version' do
      it { is_expected.to allow_value("2.0.0").for(:version) }
    end

    describe '#json' do
      it { is_expected.to match_schema('public_api/v4/packages/composer_package_version', dir: 'ee') }
      it { is_expected.to allow_value('WEIRD_JSON').for(:json) }
    end
  end
end
