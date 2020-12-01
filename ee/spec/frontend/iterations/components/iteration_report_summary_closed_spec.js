import IterationReportSummaryClosed from 'ee/iterations/components/iteration_report_summary_closed.vue';
import IterationReportSummaryCards from 'ee/iterations/components/iteration_report_summary_cards.vue';
import { shallowMount } from '@vue/test-utils';

describe('Iterations report summary', () => {
  let wrapper;

  const id = 3;
  const defaultProps = {
    iterationId: `gid://gitlab/Iteration/${id}`,
  };

  const mountComponent = ({ props = defaultProps, loading = false, data = {} } = {}) => {
    wrapper = shallowMount(IterationReportSummaryClosed, {
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
            complete: 10,
            incomplete: 3,
            total: 13,
          },
        },
      });
    });

    it('renders cards for each issue type', () => {
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
        ],
        total: 13,
      });
    });
  });
});
