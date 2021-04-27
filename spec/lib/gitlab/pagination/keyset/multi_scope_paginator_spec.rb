# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Pagination::Keyset::MultiScopePaginator do
  let_it_be(:project_1) { create(:project, name: 'aaa1', created_at: 10.weeks.ago) }
  let_it_be(:project_2) { create(:project, name: 'bbb1', created_at: 2.weeks.ago) }
  let_it_be(:project_3) { create(:project, name: 'aaa2', created_at: 4.weeks.ago) }
  let_it_be(:project_4) { create(:project, name: 'bbb2', created_at: 5.weeks.ago) }
  let_it_be(:project_5) { create(:project, name: 'aaa3', created_at: 2.weeks.ago) }
  let_it_be(:project_6) { create(:project, name: 'bbb3', created_at: 2.weeks.ago) }

  def paginator(cursor: nil)
    described_class.new(
      scopes: [
        -> { Project.where("name like 'aaa%'").order(created_at: :desc, id: :desc) },
        -> { Project.where("name like 'bbb%'").order(created_at: :desc, id: :desc) }
      ],
      sort_lambda: -> (record) { [record.created_at.to_f * -1, record.id * -1] },
      cursor: cursor,
      per_page: 2
    )
  end

  context 'when requesting the first page' do
    let(:records) { paginator.records }

    it { expect(paginator.records).to eq([project_6, project_5]) }
  end

  context 'when requesting the next page' do
    let(:records) do
      cursor = paginator.cursor_for_next_page
      paginator(cursor: cursor).records
    end

    it { expect(records).to eq([project_2, project_3]) }
  end

  context 'when requesting the last page' do
    let(:records) do
      cursor = paginator.cursor_for_last_page
      paginator(cursor: cursor).records
    end

    it { expect(records).to eq([project_4, project_1]) }
  end
end
