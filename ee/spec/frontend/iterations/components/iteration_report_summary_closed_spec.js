import IterationReportSummaryClosed from 'ee/iterations/components/iteration_report_summary_closed.vue';
import { shallowMount } from '@vue/test-utils';

describe('Iterations report summary', () => {
  let wrapper;
  let slotSpy;

  const id = 3;
  const defaultProps = {
    iterationId: `gid://gitlab/Iteration/${id}`,
  };

  const mountComponent = ({ props = defaultProps, loading = false, data = {} } = {}) => {
    slotSpy = jest.fn();

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
      scopedSlots: {
        default: slotSpy,
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
      expect(slotSpy).toHaveBeenCalledWith({
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
