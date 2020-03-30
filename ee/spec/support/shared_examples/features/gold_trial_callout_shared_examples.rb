# frozen_string_literal: true

RSpec.shared_examples 'dashboard gold trial callout' do
  before do
    sign_in(user)
  end

  it 'hides promotion callout if not .com' do
    allow(Gitlab).to receive(:com?).and_return(false)

    visit page_path

    expect(page).not_to have_selector '.promotion-callout'
  end

  describe '.com' do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    it 'shows dismissable promotion callout if default dashboard', :js do
      allow_any_instance_of(EE::DashboardHelper).to receive(:user_default_dashboard?).and_return(true)

      visit page_path

      expect(page).to have_selector '.promotion-callout'

      find('.promotion-callout .js-close').click

      expect(page).not_to have_selector '.promotion-callout'
    end

    it 'hides dismissable promotion callout if not default dashboard', :js do
      allow_any_instance_of(EE::DashboardHelper).to receive(:user_default_dashboard?).and_return(false)

      visit page_path

      expect(page).not_to have_selector '.promotion-callout'
    end

    it 'hides promotion callout if a trial is active' do
      group = create(:group, name: 'trial group', trial_ends_on: 1.year.from_now)
      group.add_owner(user)

      visit page_path

      expect(page).not_to have_selector '.promotion-callout'
    end

    it 'hides promotion callout if a gold plan is active', :js do
      group = create(:group_with_plan, name: 'gold group', plan: :gold_plan)
      group.add_owner(user)

      visit page_path

      expect(page).not_to have_selector '.promotion-callout'
    end
  end
end

RSpec.shared_examples 'billings gold trial callout' do
  context 'on a free plan' do
    let(:plan) { free_plan }

    let!(:subscription) do
      create(:gitlab_subscription, namespace: namespace, hosted_plan: nil, seats: 15)
    end

    before do
      visit page_path
    end

    it 'renders an undismissable gold trial callout' do
      expect(page).to have_selector '.promotion-callout'
      expect(page).not_to have_selector '.promotion-callout .js-close'
    end
  end

  context "on a plan that isn't gold", :js do
    let(:plans) { { bronze: create(:bronze_plan), silver: create(:silver_plan) } }

    where(case_names: ->(plan_type) {"like #{plan_type}"}, plan_type: [:bronze, :silver])

    with_them do
      let(:plan) { plans[plan_type] }

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plans[plan_type], seats: 15)
      end

      before do
        visit page_path
      end

      it 'renders a dismissable gold trial callout' do
        expect(page).to have_selector '.promotion-callout'

        find('.promotion-callout .js-close').click

        expect(page).not_to have_selector '.promotion-callout'
      end
    end
  end

  context 'on a gold plan' do
    let(:plan) { gold_plan }

    let!(:subscription) do
      create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
    end

    before do
      visit page_path
    end

    it "doesn't render a gold trial callout" do
      expect(page).not_to have_selector '.promotion-callout'
    end
  end
end
