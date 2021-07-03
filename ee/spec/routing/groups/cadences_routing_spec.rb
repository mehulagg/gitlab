# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'cadences routing' do
  let_it_be(:group_path) { 'group.abc123' }
  let_it_be(:group) { create(:group, path: group_path) }

  let(:cadence) do
    create(:iterations_cadence, group: group, title: 'test cadence')
  end

  it "routes to show cadences list" do
    expect(get("/groups/#{group_path}/-/cadences")).to route_to('groups/iteration_cadences#index', group_id: group_path)
  end

  it "routes to new cadence" do
    expect(get("/groups/#{group_path}/-/cadences/new")).to route_to('groups/iteration_cadences#index', vueroute: "new", group_id: group_path)
  end

  it "routes to edit cadence" do
    expect(get("/groups/#{group_path}/-/cadences/1/edit")).to route_to('groups/iteration_cadences#index', group_id: group_path, vueroute: "1/edit")
  end

  it "routes to list iterations within cadence" do
    expect(get("/groups/#{group_path}/-/cadences/1/iterations")).to route_to('groups/iteration_cadences#index', group_id: group_path, iteration_cadence_id: "1")
  end

  it "routes to show iteration within cadence" do
    expect(get("/groups/#{group_path}/-/cadences/1/iterations/2")).to route_to('groups/iteration_cadences#index', group_id: group_path, iteration_cadence_id: "1", id: "2")
  end

  it "routes to edit iteration within cadence" do
    expect(get("/groups/#{group_path}/-/cadences/1/iterations/2/edit")).to route_to('groups/iteration_cadences#index', group_id: group_path, iteration_cadence_id: "1", id: "2")
  end

  it "routes to new iteration within cadence" do
    expect(get("/groups/#{group_path}/-/cadences/1/iterations/new")).to route_to('groups/iteration_cadences#index', group_id: group_path, iteration_cadence_id: "1")
  end
end
