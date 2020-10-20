# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Sitemaps::UrlExtractor do
  describe '.extract' do
    subject { described_class.extract(element) }

    context 'when element is a string' do
      let(:element) { "https://gitlab.com" }

      it 'returns the string without any processing' do
        expect(subject).to eq element
      end
    end

    context 'when element is a group' do
      let(:element) { build(:group) }

      it 'calls .extract_from_group' do
        expect(described_class).to receive(:extract_from_group)

        subject
      end
    end

    context 'when element is a project' do
      let(:element) { build(:project) }

      it 'calls .extract_from_project' do
        expect(described_class).to receive(:extract_from_project)

        subject
      end
    end

    context 'when element is unknown' do
      let(:element) { build(:user) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
