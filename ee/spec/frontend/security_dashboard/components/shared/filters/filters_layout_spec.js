import { shallowMount } from '@vue/test-utils';
import ActivityFilter from 'ee/security_dashboard/components/shared/filters/activity_filter.vue';
import Filters from 'ee/security_dashboard/components/shared/filters/filters_layout.vue';
import ScannerFilter from 'ee/security_dashboard/components/shared/filters/scanner_filter.vue';
import StandardFilter from 'ee/security_dashboard/components/shared/filters/standard_filter.vue';
import { getProjectFilter } from 'ee/security_dashboard/helpers';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('First class vulnerability filters component', () => {
  let wrapper;

  const projects = [
    { id: 'gid://gitlab/Project/11', name: 'GitLab Org' },
    { id: 'gid://gitlab/Project/12', name: 'GitLab Com' },
  ];

  const findStandardFilters = () => wrapper.findAllComponents(StandardFilter);
  const findScannerFilter = () => wrapper.findComponent(ScannerFilter);
  const findActivityFilter = () => wrapper.findComponent(ActivityFilter);
  const findProjectFilter = () => wrapper.findByTestId(getProjectFilter([]).id);

  const createComponent = ({ props, provide } = {}) => {
    return extendedWrapper(
      shallowMount(Filters, {
        propsData: props,
        provide: {
          dashboardType: DASHBOARD_TYPES.PROJECT,
          ...provide,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('on render without project filter', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('should render the default filters', () => {
      expect(findStandardFilters()).toHaveLength(2);
      expect(findScannerFilter().exists()).toBe(true);
      expect(findActivityFilter().exists()).toBe(true);
      expect(findProjectFilter().exists()).toBe(false);
    });

    it('should emit filterChange when a filter is changed', () => {
      const options = { foo: 'bar' };
      findActivityFilter().vm.$emit('filter-changed', options);

      expect(wrapper.emitted('filterChange')[0][0]).toEqual(options);
    });
  });

  describe('when project filter is populated dynamically', () => {
    it('should not render the project filter if there are no options', async () => {
      wrapper = createComponent({ props: { projects: [] } });

      expect(findProjectFilter().exists()).toBe(false);
    });

    it('should render the project filter with the expected options', async () => {
      wrapper = createComponent({ props: { projects } });

      expect(findProjectFilter().props('filter').options).toEqual([
        { id: '11', name: projects[0].name },
        { id: '12', name: projects[1].name },
      ]);
    });
  });

  describe('activity filter', () => {
    beforeEach(() => {
      wrapper = createComponent({ provide: { dashboardType: DASHBOARD_TYPES.PIPELINE } });
    });

    it('does not display on the pipeline dashboard', () => {
      expect(findActivityFilter().exists()).toBe(false);
    });
  });
});
