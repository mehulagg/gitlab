import IterationReportSummary from 'ee/iterations/components/iteration_report_summary_open.vue';
import IterationReportSummaryCards from 'ee/iterations/components/iteration_report_summary_cards.vue';
import { shallowMount } from '@vue/test-utils';

describe('Iterations report summary', () => {
  let wrapper;
  const id = 3;
  const defaultProps = {
    fullPath: 'gitlab-org',
    iterationId: `gid://gitlab/Iteration/${id}`,
  };

  const mountComponent = ({ props = defaultProps, loading = false, data = {} } = {}) => {
    wrapper = shallowMount(IterationReportSummary, {
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

  describe('with valid totals', () => {
    beforeEach(() => {
      mountComponent({
        data: {
          issues: {
            closed: 10,
            assigned: 3,
            open: 5,
          },
        },
      });
    });

    it('passes data to cards component', () => {
      expect(wrapper.find(IterationReportSummaryCards).props()).toEqual({
        loading: false,
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
            value: 5,
          },
        ],
        total: 18,
      });
    });
  });
});
