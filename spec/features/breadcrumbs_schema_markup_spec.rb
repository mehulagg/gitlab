# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Breadcrumbs schema markup' do
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:issue) { create(:issue, project: project) }

  it 'generates the breadcrum schema for projects' do
    visit project_url(project)

    item_list = get_schema_content

    expect(item_list.size).to eq 3
    expect(item_list[0]['name']).to eq project.namespace.name
    expect(item_list[0]['list']).to eq user_url(project.owner)

    expect(item_list[1]['name']).to eq project.name
    expect(item_list[1]['list']).to eq project_url(project)

    expect(item_list[2]['name']).to eq 'Details'
    expect(item_list[2]['list']).to eq project_url(project)
  end

  it 'generates the breadcrum schema for issues' do
    visit project_issues_url(project)

    item_list = get_schema_content

    expect(item_list.size).to eq 3
    expect(item_list[0]['name']).to eq project.namespace.name
    expect(item_list[0]['list']).to eq user_url(project.owner)

    expect(item_list[1]['name']).to eq project.name
    expect(item_list[1]['list']).to eq project_url(project)

    expect(item_list[2]['name']).to eq 'Issues'
    expect(item_list[2]['list']).to eq project_issues_url(project)
  end

  it 'generates the breadcrum schema for specific issue' do
    visit project_issue_url(issue)

    item_list = get_schema_content

    expect(item_list.size).to eq 4
    expect(item_list[0]['name']).to eq project.namespace.name
    expect(item_list[0]['list']).to eq user_url(project.owner)

    expect(item_list[1]['name']).to eq project.name
    expect(item_list[1]['list']).to eq project_url(project)

    expect(item_list[2]['name']).to eq 'Issues'
    expect(item_list[2]['list']).to eq project_issues_url(project)

    expect(item_list[3]['name']).to eq issue.to_ref
    expect(item_list[3]['list']).to eq project_issue_url(issue)
  end

  def get_schema_content
    content = find('script[type="application/ld+json"]', visible: false).text(:all)

    expect(content).not_to be_nil

    JSON.parse(content)['itemListElement']
  end
end
