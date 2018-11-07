# frozen_string_literal: true

require 'fast_spec_helper'

describe Gitlab::Ci::Config::Normalizer do
  let(:job_name) { :rspec }
  let(:job_config) { { script: 'rspec', parallel: 5, name: 'rspec' } }
  let(:config) { { job_name => job_config } }

  describe '.normalize_jobs' do
    subject { described_class.new(config).normalize_jobs }

    it 'does not have original job' do
      is_expected.not_to include(job_name)
    end

    it 'has parallelized jobs' do
      job_names = [:"rspec 1/5", :"rspec 2/5", :"rspec 3/5", :"rspec 4/5", :"rspec 5/5"]

      is_expected.to include(*job_names)
    end

    it 'sets job instance in options' do
      expect(subject.values).to all(include(:instance))
    end

    it 'parallelizes jobs with original config' do
      original_config = config[job_name].except(:name)
      configs = subject.values.map { |config| config.except(:name, :instance) }

      expect(configs).to all(eq(original_config))
    end

    context 'when there is a job with a slash in it' do
      let(:job_name) { :"rspec 35/2" }

      it 'properly parallelizes job names' do
        job_names = [:"rspec 35/2 1/5", :"rspec 35/2 2/5", :"rspec 35/2 3/5", :"rspec 35/2 4/5", :"rspec 35/2 5/5"]

        is_expected.to include(*job_names)
      end
    end

    context 'when jobs depend on parallelized jobs' do
      let(:config) { { job_name => job_config, other_job: { script: 'echo 1', dependencies: [job_name.to_s] } } }

      it 'parallelizes dependencies' do
        job_names = ["rspec 1/5", "rspec 2/5", "rspec 3/5", "rspec 4/5", "rspec 5/5"]

        expect(subject[:other_job][:dependencies]).to include(*job_names)
      end

      it 'does not include original job name in dependencies' do
        expect(subject[:other_job][:dependencies]).not_to include(job_name)
      end
    end
  end
end
