import IterationReportSummaryCards from 'ee/iterations/components/iteration_report_summary_cards.vue';
import { mount } from '@vue/test-utils';
import { GlCard } from '@gitlab/ui';

describe('Iterations report summary cards', () => {
  let wrapper;
  const defaultProps = {
    columns: [
      {
        title: 'Completed',
        value: 10,
      },
      {
        title: 'Incomplete',
        value: 3,
      },
      {
        title: 'Unstarted',
        value: 2,
      },
    ],
    total: 15,
  };

  const mountComponent = (props = defaultProps) => {
    wrapper = mount(IterationReportSummaryCards, {
      propsData: props,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findCompleteCard = () => wrapper.findAll(GlCard).at(0);
  const findIncompleteCard = () => wrapper.findAll(GlCard).at(1);
  const findUnstartedCard = () => wrapper.findAll(GlCard).at(2);

  describe('with valid totals', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('shows completed issues', () => {
      const text = findCompleteCard().text();

      expect(text).toContain('Completed');
      expect(text).toContain('67%');
      expect(text).toContain('10 of 15');
    });

    it('shows incomplete issues', () => {
      const text = findIncompleteCard().text();

      expect(text).toContain('Incomplete');
      expect(text).toContain('20%');
      expect(text).toContain('3 of 15');
    });

    it('shows unstarted issues', () => {
      const text = findUnstartedCard().text();

      expect(text).toContain('Unstarted');
      expect(text).toContain('13%');
      expect(text).toContain('2 of 15');
    });
  });

  it('hides "of" text if total is 0', () => {
    mountComponent({
      ...defaultProps,
      total: 0,
    });

    expect(findCompleteCard().text()).not.toContain('of');
    expect(findIncompleteCard().text()).not.toContain('of');
    expect(findUnstartedCard().text()).not.toContain('of');
  });
});
