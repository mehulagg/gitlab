# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project Insights' do
  it_behaves_like 'Insights page' do
    let_it_be(:entity) { create(:project) }
    let(:route) { url_for([entity.namespace, entity, :insights]) }
    let(:path) { project_insights_path(entity) }
  end
end
