# frozen_string_literal: true

require_relative '../../../../tooling/lib/tooling/parallel_rspec_runner'

RSpec.describe Tooling::ParallelRSpecRunner do # rubocop:disable RSpec/FilePath
  describe '#run' do
    let(:allocator) { instance_double(Knapsack::Allocator) }
    let(:rspec_args) { '--no-color --seed 123' }
    let(:matching_tests_file) { 'tests.txt' }
    let(:node_tests) { %w[01_spec.rb 03_spec.rb 05_spec.rb] }
    let(:matching_tests) { '01_spec.rb 02_spec.rb 03_spec.rb' }
    let(:test_dir) { 'spec' }

    before do
      allow(Knapsack.logger).to receive(:info)
      allow(allocator).to receive(:node_tests).and_return(node_tests)
      allow(allocator).to receive(:test_dir).and_return(test_dir)
      allow(File).to receive(:read).with(matching_tests_file).and_return(matching_tests)
      allow_any_instance_of(described_class).to receive(:exec)
    end

    subject { described_class.new(allocator: allocator, matching_tests_file: matching_tests_file, rspec_args: rspec_args) }

    it 'reads matching tests file for list of tests' do
      expect(File).to receive(:read).with(matching_tests_file)

      subject.run
    end

    context 'given matching tests' do
      it 'runs rspec matching tests that are allocated for this node' do
        expected_tests = '01_spec.rb 03_spec.rb'
        expect_any_instance_of(described_class).to receive(:exec).with(rspec_command(expected_tests))

        subject.run
      end
    end

    shared_examples 'runs node tests' do
      it 'runs rspec with tests allocated for this node' do
        expected_tests = '01_spec.rb 03_spec.rb 05_spec.rb'
        expect_any_instance_of(described_class).to receive(:exec).with(rspec_command(expected_tests))

        subject.run
      end
    end

    context 'with empty matching tests' do
      let(:matching_tests) { '' }

      it_behaves_like 'runs node tests'
    end

    context 'if file does not exist' do
      before do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)
      end

      it_behaves_like 'runs node tests'
    end

    def rspec_command(tests)
      %Q[bundle exec rspec #{rspec_args} --default-path #{test_dir} -- #{tests}]
    end
  end
end
