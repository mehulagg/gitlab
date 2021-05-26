# frozen_string_literal: true

require 'generator_helper'

RSpec.describe Gitlab::UsageMetricGenerator do
  let(:ce_temp_dir) { Dir.mktmpdir }
  let(:ee_temp_dir) { Dir.mktmpdir }
  let(:spec_ce_temp_dir) { Dir.mktmpdir }
  let(:spec_ee_temp_dir) { Dir.mktmpdir }
  let(:args) { ['CountFoo'] }
  let(:options) { { 'type' => 'redis_hll' } }

  before do
    stub_const("#{described_class}::CE_DIR", ce_temp_dir)
    stub_const("#{described_class}::EE_DIR", ee_temp_dir)
    stub_const("#{described_class}::SPEC_CE_DIR", spec_ce_temp_dir)
    stub_const("#{described_class}::SPEC_EE_DIR", spec_ee_temp_dir)
  end

  after do
    FileUtils.rm_rf([ce_temp_dir, ee_temp_dir, spec_ce_temp_dir, spec_ee_temp_dir])
  end

  describe 'Creating metric instrumentation files' do
    let(:sample_metric_dir) { 'lib/generators/gitlab/usage_metric_generator' }
    let(:sample_metric) { fixture_file(File.join(sample_metric_dir, 'sample_metric.rb')) }
    let(:sample_spec) { fixture_file(File.join(sample_metric_dir, 'sample_metric_spec.rb')) }

    it 'creates CE metric instrumentation file using the template' do
      described_class.new(args, options).invoke_all

      file_path = File.join(ce_temp_dir, 'count_foo_metric.rb')
      file = File.read(file_path)

      expect(file).to eq(sample_metric)
    end

    it 'creates CE metric instrumentation spec file using the template' do
      described_class.new(args, options).invoke_all

      file_path = File.join(spec_ce_temp_dir, 'count_foo_metric_spec.rb')
      file = File.read(file_path)

      expect(file).to eq(sample_spec)
    end

    context 'with EE flag true' do
      let(:options) { { 'type' => 'redis_hll', 'ee' => true } }

      it 'creates EE metric instrumentation file using the template' do
        described_class.new(args, options).invoke_all

        file_path = File.join(ee_temp_dir, 'count_foo_metric.rb')
        file = File.read(file_path)

        expect(file).to eq(sample_metric)
      end

      it 'creates EE metric instrumentation spec file using the template' do
        described_class.new(args, options).invoke_all

        file_path = File.join(spec_ee_temp_dir, 'count_foo_metric_spec.rb')
        file = File.read(file_path)

        expect(file).to eq(sample_spec)
      end
    end
  end
end
