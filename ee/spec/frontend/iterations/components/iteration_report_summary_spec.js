import IterationReportSummary from 'ee/iterations/components/iteration_report_summary.vue';
import { mount } from '@vue/test-utils';
import { GlCard } from '@gitlab/ui';

describe('Iterations report summary', () => {
  let wrapper;
  const id = 3;
  const defaultProps = {
    iterationId: `gid://gitlab/Iteration/${id}`,
  };

  const mountComponent = ({ props = defaultProps, loading = false, data = {} } = {}) => {
    wrapper = mount(IterationReportSummary, {
      propsData: props,
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          queries: { issues: { loading } },
        },
      },
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

      wrapper.setData({
        issues: {
          complete: 10,
          incomplete: 3,
          total: 15,
        },
      });
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

  describe('with no issues', () => {
    beforeEach(() => {
      mountComponent();

      wrapper.setData({
        issues: {
          complete: 0,
          incomplete: 0,
          total: 0,
        },
      });
    });

    it('shows complete percentage', () => {
      expect(findCompleteCard().text()).toContain('0');
      expect(findIncompleteCard().text()).toContain('0');
      expect(findUnstartedCard().text()).toContain('0');
    });
  });
});
