# frozen_string_literal: true

require 'knapsack'

# A custom parallel rspec runner based on Knapsack runner
# which takes in additional option for a file containing
# list of test files.
#
# When executing RSpec in CI, the list of tests allocated by Knapsack
# will be compared with the test files listed in the file.
#
# Only the test files allocated by Knapsack and listed in the file
# would be executed in the CI node.
module Tooling
  class ParallelRSpecRunner
    def self.run(rspec_args: nil, matching_tests_file: nil)
      new(rspec_args: rspec_args, matching_tests_file: matching_tests_file).run
    end

    def initialize(allocator: knapsack_allocator, matching_tests_file: nil, rspec_args: nil)
      @allocator = allocator
      @matching_tests = matching_tests_file ? tests_from_file(matching_tests_file) : []
      @rspec_args = rspec_args
    end

    def run
      Knapsack.logger.info
      Knapsack.logger.info 'Knapsack node specs:'
      Knapsack.logger.info node_tests
      Knapsack.logger.info
      Knapsack.logger.info 'Matching specs:'
      Knapsack.logger.info matching_tests
      Knapsack.logger.info
      Knapsack.logger.info 'Running specs:'
      Knapsack.logger.info tests_to_run
      Knapsack.logger.info

      cmd = %Q[bundle exec rspec #{rspec_args} --default-path #{allocator.test_dir} -- #{tests_to_run.join(' ')}]

      exec(cmd)
    end

    private

    attr_reader :allocator, :matching_tests, :rspec_args

    def tests_from_file(shortlist_tests_file)
      File.read(shortlist_tests_file).split(' ')
    rescue Errno::ENOENT
      []
    end

    def tests_to_run
      return node_tests if matching_tests.empty?

      matching_tests & node_tests
    end

    def node_tests
      allocator.node_tests
    end

    def knapsack_allocator
      Knapsack::AllocatorBuilder.new(Knapsack::Adapters::RSpecAdapter).allocator
    end
  end
end
