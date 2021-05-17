# frozen_string_literal: true
def text(text)
  puts "--------------"
  puts text
  puts "--------------"
end

def print_records(records)
  puts "author_id, id"

  records.each do |record|
    puts "#{record.author_id}, #{record.created_at}, #{record.id}"
  end
end

# Array of ActiveRecord scopes that can trigger queries on different shards
scopes = [
  # rubocop: disable CodeReuse/ActiveRecord
  -> {
    # ShardSelector(id: shard_id) do
    Issue.where(author_id: 15).order(created_at: :asc, id: :asc)
    # end
  },
  # rubocop: enable CodeReuse/ActiveRecord,
  # rubocop: disable CodeReuse/ActiveRecord
  -> { Issue.where(author_id: 18).order(created_at: :asc, id: :asc) },
  # rubocop: enable CodeReuse/ActiveRecord,
  # rubocop: disable CodeReuse/ActiveRecord
  -> { Issue.where(author_id: 20).order(created_at: :asc, id: :asc) }
  # rubocop: enable CodeReuse/ActiveRecord
]

sort_lambda = -> (record) { [record.created_at, record.id] }

paginator = Gitlab::Pagination::Keyset::ShardAwarePaginator.new(scopes: scopes, per_page: 10, sort_lambda: sort_lambda)

text "records for 1. page"
print_records(paginator.records)
cursor = paginator.cursor_for_next_page

paginator = Gitlab::Pagination::Keyset::ShardAwarePaginator.new(scopes: scopes, cursor: cursor, per_page: 10, sort_lambda: sort_lambda)

text "records for 2. page"
print_records(paginator.records)
cursor = paginator.cursor_for_next_page

paginator = Gitlab::Pagination::Keyset::ShardAwarePaginator.new(scopes: scopes, cursor: cursor, per_page: 10, sort_lambda: sort_lambda)

text "records for 3. page"
print_records(paginator.records)

text "jumping back to the first page"

cursor = paginator.cursor_for_first_page

paginator = Gitlab::Pagination::Keyset::ShardAwarePaginator.new(scopes: scopes, cursor: cursor, per_page: 10, sort_lambda: sort_lambda)

text "records for 1. page"
print_records(paginator.records)

cursor = paginator.cursor_for_last_page

paginator = Gitlab::Pagination::Keyset::ShardAwarePaginator.new(scopes: scopes, cursor: cursor, per_page: 10, sort_lambda: sort_lambda)

text "records for last page"
print_records(paginator.records)
