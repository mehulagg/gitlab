# frozen_string_literal: true

module PaginatorExtension
  def keyset_paginate(cursor: nil, per_page: 5)
    Gitlab::Pagination::Keyset::Paginator.new(scope: self, cursor: cursor, per_page: per_page)
  end

  delegate :has_next_page?, :has_previous_page?, :cursor_for_next_page, :cursor_for_previous_page, to: :keyset_paginator
end
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(PaginatorExtension)
end
