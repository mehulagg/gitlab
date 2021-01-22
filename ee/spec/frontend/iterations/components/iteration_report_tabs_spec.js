import { GlBadge, GlFormSelect } from '@gitlab/ui';
import { getByText } from '@testing-library/dom';
import { mount, shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import IterationReportIssues from 'ee/iterations/components/iteration_report_issues.vue';
import IterationReportTabs from 'ee/iterations/components/iteration_report_tabs.vue';
import { GroupBy, Namespace } from 'ee/iterations/constants';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

describe('Iterations report tabs', () => {
  let wrapper;
  const id = 3;
  const fullPath = 'gitlab-org';
  const defaultProps = {
    fullPath,
    iterationId: `gid://gitlab/Iteration/${id}`,
    namespaceType: Namespace.Group,
  };

  const findGlFormSelectOptionAt = (index) =>
    wrapper.find(GlFormSelect).findAll('option').at(index);
  const findIterationReportIssuesAt = (index) => wrapper.findAll(IterationReportIssues).at(index);
  const findLabelsSelect = () => wrapper.find(LabelsSelect);

  const mountComponent = ({
    props = defaultProps,
    loading = false,
    data = {},
    mountFunction = shallowMount,
  } = {}) => {
    wrapper = mountFunction(IterationReportTabs, {
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

  describe('IterationReportIssues component', () => {
    it('is rendered', () => {
      mountComponent();

      expect(wrapper.find(IterationReportIssues).isVisible()).toBe(true);
    });

    it('updates the issue count when issueCount is emitted', async () => {
      mountComponent({ mountFunction: mount });

      const issueCount = 7;

      wrapper.find(IterationReportIssues).vm.$emit('issueCount', issueCount);

      await nextTick();

      expect(wrapper.find(GlBadge).text()).toBe(issueCount.toString());
    });
  });

  describe('group by section', () => {
    describe('select dropdown', () => {
      beforeEach(() => {
        mountComponent({ mountFunction: mount });
      });

      it('shows label', () => {
        expect(getByText(wrapper.element, 'Group by')).not.toBeNull();
      });

      it('has `None` option', () => {
        expect(findGlFormSelectOptionAt(0).text()).toBe('None');
      });

      it('has `Label` option', () => {
        expect(findGlFormSelectOptionAt(1).text()).toBe('Label');
      });
    });

    describe('label picker', () => {
      describe('when group by `None` option is selected', () => {
        beforeEach(() => {
          mountComponent();
        });

        it('is not shown', () => {
          expect(findLabelsSelect().exists()).toBe(false);
        });
      });

      describe('when group by `Label` option is selected', () => {
        beforeEach(() => {
          mountComponent({ data: { groupBySelection: GroupBy.Label } });
        });

        it('is shown', () => {
          expect(getByText(wrapper.element, 'Filter by label')).not.toBeNull();
          expect(findLabelsSelect().exists()).toBe(true);
        });
      });
    });
  });

  describe('issues grouped by labels', () => {
    beforeEach(() => {
      mountComponent({ data: { groupBySelection: GroupBy.Label } });
    });

    describe('when labels are selected', () => {
      const selectedLabels = [
        {
          id: 40,
          title: 'Security',
          color: '#ddd',
          text_color: '#fff',
          set: true,
        },
        {
          id: 55,
          title: 'Tooling',
          color: '#ddd',
          text_color: '#fff',
          set: true,
        },
      ];

      beforeEach(() => {
        findLabelsSelect().vm.$emit('updateSelectedLabels', selectedLabels);
      });

      it('shows issues for `Security` label', () => {
        expect(findIterationReportIssuesAt(0).props()).toEqual({
          ...defaultProps,
          label: selectedLabels[0],
        });
      });

      it('shows issues for `Tooling` label', () => {
        expect(findIterationReportIssuesAt(1).props()).toEqual({
          ...defaultProps,
          label: selectedLabels[1],
        });
      });

      it('hides issues for the ungrouped issues list', () => {
        expect(findIterationReportIssuesAt(2).isVisible()).toBe(false);
      });
    });
  });
});
