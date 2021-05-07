# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/users/index' do
  let(:should_check_namespace_plan) { false }

  before do
    allow(Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?)
      .and_return(should_check_namespace_plan)
    allow(view).to receive(:container_class).and_return('ignored')
    create(:user) # to have at least one usser
    assign(:users, User.all.page(1))
    assign(:cohorts, { months_included: 0, cohorts: [] })

    render
  end

  it 'includes "Send email to users" link' do
    expect(rendered).to have_link href: admin_email_path
  end

  context 'when Gitlab::CurrentSettings.should_check_namespace_plan is true' do
    let(:should_check_namespace_plan) { true }

    it 'includes "Send email to users" link' do
      expect(rendered).to have_link href: admin_email_path
    end
  end
end
