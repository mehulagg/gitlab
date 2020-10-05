# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Issue'] do
  it { expect(described_class).to have_graphql_field(:epic) }

  it { expect(described_class).to have_graphql_field(:iteration) }

  it { expect(described_class).to have_graphql_field(:weight) }

  it { expect(described_class).to have_graphql_field(:health_status) }

  it { expect(described_class).to have_graphql_field(:blocked) }

  context 'N+1 queries' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, :public, group: group) }
    let_it_be(:project_path) { project.full_path }
    let!(:blocking_issue1) { create(:issue, project: project) }
    let!(:blocked_issue1) { create(:issue, project: project) }
    let!(:issue_link1) { create :issue_link, source: blocking_issue1, target: blocked_issue1, link_type: IssueLink::TYPE_BLOCKS }

    shared_examples 'avoids N+1 queries on blocked' do
      specify do
        control_count = ActiveRecord::QueryRecorder.new { GitlabSchema.execute(query, context: { current_user: user }) }.count

        blocked_issue2 = create(:issue, project: project)
        blocking_issue2 = create(:issue, project: project)
        create :issue_link, source: blocked_issue2, target: blocking_issue2, link_type: IssueLink::TYPE_IS_BLOCKED_BY

        # added the +1 due to an existing N+1 with issues
        expect { GitlabSchema.execute(query, context: { current_user: user }) }.not_to exceed_query_limit(control_count + 1)
      end
    end

    context 'group issues' do
      let(:query) do
        %(
          query{
            group(fullPath:"#{group.full_path}"){
              issues{
                nodes{
                  title
                  blocked
                }
              }
            }
          }
        )
      end

      it_behaves_like 'avoids N+1 queries on blocked'
    end

    context 'project issues' do
      let(:query) do
        %(
          query{
            project(fullPath:"#{project_path}"){
              issues{
                nodes{
                  title
                  blocked
                }
              }
            }
          }
        )
      end

      it_behaves_like 'avoids N+1 queries on blocked'
    end
  end
end
