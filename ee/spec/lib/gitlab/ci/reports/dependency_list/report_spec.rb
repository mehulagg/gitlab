# frozen_string_literal: true

require 'spec_helper'
require 'benchmark/ips'

RSpec.describe Gitlab::Ci::Reports::DependencyList::Report do
  let(:report) { described_class.new }

  describe '#add_dependency' do
    let(:dependency) do
      {
        name: 'gitlab',
        packager: '',
        package_manager: 'bundler',
        location: { blob_path: '', path: 'Gemfile' },
        version: '0.2.10',
        vulnerabilities: [],
        licenses: []
      }
    end

    subject { report.add_dependency(dependency) }

    it 'stores given dependency params in the map' do
      subject

      expect(report.dependencies).to eq([dependency])
    end

    it 'does not duplicate same dependency' do
      report.add_dependency(dependency)
      report.add_dependency(dependency.dup)

      expect(report.dependencies.first).to eq(dependency)
    end

    it 'does not duplicate same vulnerability for dependency' do
      vulnerabilities = [{ name: 'problem', severity: 'high' }, { name: 'problem2', severity: 'medium' }]
      dependency[:vulnerabilities] = [vulnerabilities.first]
      with_extra_vuln_from_another_report = dependency.dup.merge(vulnerabilities: vulnerabilities)

      report.add_dependency(dependency)
      report.add_dependency(with_extra_vuln_from_another_report)
      expect(report.dependencies.first.dig(:vulnerabilities)).to eq(vulnerabilities)
    end

    it 'updates dependency' do
      dependency[:packager] = 'Ruby (Bundler)'
      dependency[:vulnerabilities] = [{ name: 'abc', severity: 'high' }]

      report.add_dependency(dependency)
      expect(report.dependencies.size).to eq(1)
      expect(report.dependencies.first[:packager]).to eq('Ruby (Bundler)')
      expect(report.dependencies.first[:vulnerabilities]).to eq([{ name: 'abc', severity: 'high' }])
    end
  end

  describe '#apply_license' do
    subject { report.dependencies.last[:licenses].size }

    let(:license) { build(:ci_reports_license_scanning_report, :mit).licenses.first }

    before do
      license.add_dependency(name_of_dependency_with_license)
      report.add_dependency(dependency)
      report.apply_license(license)
    end

    context 'with matching dependency' do
      let(:name_of_dependency_with_license) { dependency[:name] }

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
      let(:name_of_dependency_with_license) { dependency[:name].reverse }

      it 'does not apply the license at all' do
        is_expected.to eq(0)
      end
    end
  end

  describe '#dependencies_with_licenses' do
    subject { report.dependencies_with_licenses }

    context 'with found dependencies' do
      let(:plain_dependency) { build :dependency }

      before do
        report.add_dependency(plain_dependency)
      end

      context 'with existing license' do
        let(:dependency) { build :dependency, :with_licenses }

        before do
          report.add_dependency(dependency)
        end

        it 'returns only dependency with license' do
          expect(subject.size).to eq(1)
          expect(subject.first).to eq(dependency)
        end
      end

      context 'without existing license' do
        it 'returns empty array' do
          expect(subject).to be_empty
        end
      end
    end

    context 'without found dependencies' do
      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end
  end
end
