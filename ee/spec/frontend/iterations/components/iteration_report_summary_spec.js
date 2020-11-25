import { GlCard } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import IterationReportSummary from 'ee/iterations/components/iteration_report_summary.vue';
import { Namespace } from 'ee/iterations/constants';

describe('Iterations report summary', () => {
  let wrapper;
  const id = 3;
  const fullPath = 'gitlab-org';
  const defaultProps = {
    fullPath,
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

  const findPercentageCard = () => wrapper.findAll(GlCard).at(0);
  const findOpenCard = () => wrapper.findAll(GlCard).at(1);
  const findInProgressCard = () => wrapper.findAll(GlCard).at(2);
  const findCompletedCard = () => wrapper.findAll(GlCard).at(3);

  describe('with valid totals', () => {
    beforeEach(() => {
      mountComponent();

      wrapper.setData({
        issues: {
          open: 15,
          assigned: 5,
          closed: 10,
        },
      });
    });

    it('shows complete percentage', () => {
      expect(findPercentageCard().text()).toContain('33%');
    });

    it('shows open issues', () => {
      expect(findOpenCard().text()).toContain('Open');
      expect(findOpenCard().text()).toContain('15');
    });

    it('shows in progress issues', () => {
      expect(findInProgressCard().text()).toContain('In progress');
      expect(findInProgressCard().text()).toContain('5');
    });

    it('shows completed issues', () => {
      expect(findCompletedCard().text()).toContain('Completed');
      expect(findCompletedCard().text()).toContain('10');
    });
  });

  describe('with no issues', () => {
    beforeEach(() => {
      mountComponent();

      wrapper.setData({
        issues: {
          open: 0,
          assigned: 0,
          closed: 0,
        },
      });
    });

    it('shows complete percentage', () => {
      expect(findPercentageCard().text()).toContain('0%');
      expect(findOpenCard().text()).toContain('0');
      expect(findInProgressCard().text()).toContain('0');
      expect(findCompletedCard().text()).toContain('0');
    });
  });

  describe('IterationIssuesSummary query variables', () => {
    const expected = {
      fullPath: defaultProps.fullPath,
      id,
    };

    describe('when group', () => {
      it('has expected query variable values', () => {
        mountComponent({
          props: {
            ...defaultProps,
            namespaceType: Namespace.Group,
          },
        });

        expect(wrapper.vm.queryVariables).toEqual({
          ...expected,
          isGroup: true,
        });
      });
    });

    describe('when project', () => {
      it('has expected query variable values', () => {
        mountComponent({
          props: {
            ...defaultProps,
            namespaceType: Namespace.Project,
          },
        });

        expect(wrapper.vm.queryVariables).toEqual({
          ...expected,
          isGroup: false,
        });
      });
    });
  });
});
