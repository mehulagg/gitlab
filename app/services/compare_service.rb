# frozen_string_literal: true

require 'securerandom'

# Compare 2 refs for one repo or between repositories
# and return Compare object that responds to commits and diffs
class CompareService
  attr_reader :start_repository, :start_ref_name

  def initialize(start_repository, start_ref_name)
    @start_repository = start_repository
    @start_ref_name = start_ref_name
  end

  def execute(target_repository, target_ref, base_sha: nil, straight: false)
    raw_compare = target_repository.compare_source_branch(target_ref, start_repository, start_ref_name, straight: straight)

    return unless raw_compare && raw_compare.base && raw_compare.head

    Compare.new(raw_compare,
                target_repository,
                base_sha: base_sha,
                straight: straight)
  end
end
