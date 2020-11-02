# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::DependencyList::Dependency do
  let(:dependency_nokogiri) { build(:dependency, :nokogiri, :with_vulnerabilities) }

  context 'initialize' do
    specify do
      dependency_nokogiri[:location] = { blob_path: 'path/File_21.lock', path: 'File_21.lock' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.to_hash).to eq({ name: 'nokogiri',
                                  packager: 'Ruby (Bundler)',
                                  package_manager: 'Ruby (Bundler)',
                                  location: { blob_path: 'path/File_21.lock', path: 'File_21.lock' },
                                  version: '1.8.0',
                                  licenses: [],
                                   vulnerabilities: [{ name: 'DDoS', severity: 'high' }, { name: 'XSS vulnerability', severity: 'low' }] })
    end

    specify do
      dependency_nokogiri[:vulnerabilities] << { name: 'problem', severity: 'high' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.vulnerabilities.to_a.map(&:to_hash)).to eq([{ name: 'DDoS', severity: 'high' },
                                                             { name: 'XSS vulnerability', severity: 'low' },
                                                             { name: 'problem', severity: 'high' }])
    end

    specify do
      dependency_nokogiri[:vulnerabilities] << { name: 'DDoS', severity: 'high' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.vulnerabilities.to_a.map(&:to_hash)).to eq([{ name: 'DDoS', severity: 'high' },
                                                             { name: 'XSS vulnerability', severity: 'low' }])
    end
  end

  context 'update dependency' do
    specify do
      dependency_nokogiri[:vulnerabilities] << { name: 'DDoS', severity: 'high' } << { name: 'problem', severity: 'high' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.vulnerabilities.to_a.map(&:to_hash)).to eq([{ name: 'DDoS', severity: 'high' },
                                                             { name: 'XSS vulnerability', severity: 'low' },
                                                             { name: 'problem', severity: 'high' }])
    end
  end
end
