# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::SetAll do
  it 'is possible to update all objects in a single query' do
    users = create_list(:user, 3)
    mapping = users.zip(%w(foo bar baz)).to_h do |u, name|
      [u, { username: name, admin: true }]
    end

    described_class.set_all(%i[username admin], mapping)

    # We have optimistically updated the values
    expect(users).to all(be_admin)
    expect(users.map(&:username)).to eq(%w(foo bar baz))

    users.each(&:reset)

    # The values are correct on reset
    expect(users).to all(be_admin)
    expect(users.map(&:username)).to eq(%w(foo bar baz))
  end

  it 'is possible to update heterogeneous sets' do
    create_default(:user)
    create_default(:project)

    mr_a = create(:merge_request)
    i_a, i_b = create_list(:issue, 2)

    mapping = {
      mr_a => { title: 'MR a' },
      i_a  => { title: 'Issue a' },
      i_b  => { title: 'Issue b' }
    }

    described_class.set_all(%i[title], mapping)

    expect([mr_a, i_a, i_b].map { |x| x.reset.title })
      .to eq(['MR a', 'Issue a', 'Issue b'])
  end
end
