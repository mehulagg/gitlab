# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::DependencyList::Report do
  let(:report) { described_class.new }

  describe '#add_dependency' do
    let(:dependency) { { name: 'gitlab', version: '12.0' } }

    subject { report.add_dependency(dependency) }

    it 'stores given dependency params in the map' do
      subject

      expect(report.dependencies).to eq([dependency])
    end
  end

  describe '#apply_license' do
    subject { report.dependencies.last[:licenses].size }

    let(:license) do
      {
        dependency: {
          name: 'nokogiri'
        },
        license: {
          name:       'MIT',
          url:        'http://opensource.org/licenses/mit-license'
        }
      }
    end

    before do
      report.add_dependency(dependency)
      report.apply_license(license)
    end

    context 'with matching dependency' do
      context 'with empty license list' do
        let(:dependency) { build :dependency }

        it 'applies license' do
          is_expected.to eq(1)
        end
      end

      context 'with full license list' do
        let(:dependency) { build :dependency, :with_licenses }

        it 'does not apply the license a second time' do
          is_expected.to eq(1)
        end
      end
    end

    context 'without matching dependency' do
      let(:dependency) { build :dependency, name: 'irigokon' }

      it 'does not apply the license at all' do
        is_expected.to eq(0)
      end
    end
  end
end
