# frozen_string_literal: true

class IssueRebalancingService
  MAX_ISSUE_COUNT = 10_000
  BATCH_SIZE = 100
  RETRIES = 10
  TooManyIssues = Class.new(StandardError)

  def initialize(issue)
    @issue = issue
    @base = Issue.relative_positioning_query_base(issue)
  end

  def execute
    batch = BATCH_SIZE
    retries = 0
    gates = [issue.project, issue.project.group].compact
    return unless gates.any? { |gate| Feature.enabled?(:rebalance_issues, gate) }

    raise TooManyIssues, "#{issue_count} issues" if issue_count > MAX_ISSUE_COUNT

    start = RelativePositioning::START_POSITION - (gaps / 2) * gap_size

    if Feature.enabled?(:issue_rebalancing_optimization)
      Issue.transaction do
        retries = 0
        begin
          assign_positions(start, indexed_ids)
            .sort_by(&:first)
            .each_slice(batch) do |pairs_with_position|
            update_positions(pairs_with_position, 'rebalance issue positions in batches ordered by id')
          rescue ActiveRecord::StatementTimeout
            if (retries += 1) <= RETRIES
              batch = (batch / 3).to_i if retries % 3 == 0 # shrink the batch size in half every 3rd retry
              # replace the first item in the list with 2 arrays of half the size
              retry
            end
          end
        end
      end
    else
      Issue.transaction do
        retries = 0
        begin
          indexed_ids.each_slice(batch) do |pairs|
            pairs_with_position = assign_positions(start, pairs)
            update_positions(pairs_with_position, 'rebalance issue positions')
          rescue ActiveRecord::StatementTimeout
            if (retries += 1) <= RETRIES
              batch = (batch / 3).to_i if retries % 3 == 0 # shrink the batch size in half every 3rd retry
              retry
            end
          end
        end
      end
    end
  end

  private

  attr_reader :issue, :base

  # rubocop: disable CodeReuse/ActiveRecord
  def indexed_ids
    base.reorder(:relative_position, :id).pluck(:id).each_with_index
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def assign_positions(start, pairs)
    pairs.map do |id, index|
      [id, start + (index * gap_size)]
    end
  end

  def update_positions(pairs_with_position, query_name)
    values = pairs_with_position.map do |id, index|
      "(#{id}, #{index})"
    end.join(', ')

    run_update_query(values, query_name)
  end

  def run_update_query(values, query_name)
    Issue.connection.exec_query(<<~SQL, query_name)
      WITH cte(cte_id, new_pos) AS #{Gitlab::Database::AsWithMaterialized.materialized_if_supported} (
       SELECT *
       FROM (VALUES #{values}) as t (id, pos)
      )
      UPDATE #{Issue.table_name}
      SET relative_position = cte.new_pos
      FROM cte
      WHERE cte_id = id
    SQL
  end

  def issue_count
    @issue_count ||= base.count
  end

  def gaps
    issue_count - 1
  end

  def gap_size
    # We could try to split the available range over the number of gaps we need,
    # but IDEAL_DISTANCE * MAX_ISSUE_COUNT is only 0.1% of the available range,
    # so we are guaranteed not to exhaust it by using this static value.
    #
    # If we raise MAX_ISSUE_COUNT or IDEAL_DISTANCE significantly, this may
    # change!
    RelativePositioning::IDEAL_DISTANCE
  end
end
