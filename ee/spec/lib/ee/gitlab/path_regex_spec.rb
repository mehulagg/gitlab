# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::PathRegex do
  describe '.container_image_regex' do
    subject { described_class.container_image_regex }

    it { is_expected.to match('gitlab-foss') }
    it { is_expected.to match('gitlab_foss') }
    it { is_expected.to match('gitlab-org/gitlab-foss') }
    it { is_expected.to match('100px.com/100px.ruby') }

    it 'only matches at most one slash' do
      expect(subject.match('foo/bar/baz')[0]).to eq('foo/bar')
    end

    it 'does not match other non-word characters' do
      expect(subject.match('ruby:2.7.0')[0]).to eq('ruby')
    end
  end

  describe '.container_image_blob_sha_regex' do
    subject { described_class.container_image_blob_sha_regex }

    it { is_expected.to match('sha256:asdf1234567890ASDF') }
    it { is_expected.to match('foo:123') }
    it { is_expected.to match('a12bc3f590szp') }
    it { is_expected.not_to match('') }

    it 'does not match malicious characters' do
      expect(subject.match('sha256:asdf1234%2f')[0]).to eq('sha256:asdf1234')
    end
  end
end
