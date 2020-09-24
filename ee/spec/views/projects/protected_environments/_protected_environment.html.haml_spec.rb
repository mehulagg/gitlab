# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/protected_environments/_protected_environment' do
  it 'displays protected environments without matching environment as text' do
    protected_environment = build_stubbed(:protected_environment, name: 'production')
    expect(protected_environment).to receive(:environment_id?).and_return(false)
    assign :project, protected_environment.project

    render partial: 'projects/protected_environments/protected_environment', locals: { protected_environment: protected_environment, can_admin_project: true }

    expect(rendered).to have_text('production')
    expect(rendered).not_to have_link('production')
  end

  it 'displays protected environments with matching environment as link' do
    protected_environment = build_stubbed(:protected_environment, name: 'production')
    expect(protected_environment).to receive(:environment_id?).and_return(true)
    expect(protected_environment).to receive(:environment_id).and_return(314)
    assign :project, protected_environment.project

    render partial: 'projects/protected_environments/protected_environment', locals: { protected_environment: protected_environment, can_admin_project: true }

    expect(rendered).to have_link('production', href: project_environment_path(protected_environment.project, 314))
  end
end
