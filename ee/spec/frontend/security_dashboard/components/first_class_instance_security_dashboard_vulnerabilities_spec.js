import { GlAlert, GlTable, GlEmptyState, GlIntersectionObserver, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import FirstClassInstanceVulnerabilities from 'ee/security_dashboard/components/first_class_instance_security_dashboard_vulnerabilities.vue';
import VulnerabilityList from 'ee/security_dashboard/components/vulnerability_list.vue';
import { generateVulnerabilities } from './mock_data';

describe('First Class Instance Dashboard Vulnerabilities Component', () => {
  let wrapper;

  const findIntersectionObserver = () => wrapper.find(GlIntersectionObserver);
  const findVulnerabilities = () => wrapper.find(VulnerabilityList);
  const findAlert = () => wrapper.find(GlAlert);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  const expectLoadingState = ({ initial = false, nextPage = false }) => {
    expect(findVulnerabilities().props('isLoading')).toBe(initial);
    expect(findLoadingIcon().exists()).toBe(nextPage);
  };

  const createWrapper = ({ stubs, loading = false, data } = {}) => {
    return shallowMount(FirstClassInstanceVulnerabilities, {
      stubs,
      mocks: {
        $apollo: {
          queries: { vulnerabilities: { loading } },
        },
        fetchNextPage: () => {},
      },
      data,
      provide: {
        hasVulnerabilities: true,
        hasJiraVulnerabilitiesIntegrationEnabled: false,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when the query is loading', () => {
    beforeEach(() => {
      wrapper = createWrapper({ loading: true });
    });

    it('shows the initial loading state', () => {
      expectLoadingState({ initial: true });
    });
  });

  describe('when the query returned an error status', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        stubs: {
          GlAlert,
        },
        data: () => ({ errorLoadingVulnerabilities: true }),
      });
    });

    it('displays the alert', () => {
      expect(findAlert().text()).toBe(
        'Error fetching the vulnerability list. Please check your network connection and try again.',
      );
    });

    it('should have an alert that is dismissable', () => {
      const alert = findAlert();
      alert.vm.$emit('dismiss');
      return wrapper.vm.$nextTick(() => {
        expect(alert.exists()).toBe(false);
      });
    });

    it('does not display the vulnerabilities', () => {
      expect(findVulnerabilities().exists()).toBe(false);
    });
  });

  describe('when the query is loaded and we have results', () => {
    const vulnerabilities = generateVulnerabilities();

    beforeEach(() => {
      wrapper = createWrapper({
        stubs: {
          VulnerabilityList,
          GlTable,
          GlEmptyState,
        },
        data: () => ({ vulnerabilities }),
      });
    });

    it('passes down properties correctly', () => {
      expect(findVulnerabilities().props()).toEqual({
        filters: {},
        isLoading: false,
        securityScanners: {},
        shouldShowSelection: true,
        shouldShowProjectNamespace: true,
        vulnerabilities,
      });
    });

    it('defaults to severity column for sorting', () => {
      expect(wrapper.vm.sortBy).toBe('severity');
    });

    it('defaults to desc as sorting direction', () => {
      expect(wrapper.vm.sortDirection).toBe('desc');
    });

    it('handles sorting', () => {
      findVulnerabilities().vm.$listeners['sort-changed']({
        sortBy: 'description',
        sortDesc: false,
      });
      expect(wrapper.vm.sortBy).toBe('description');
      expect(wrapper.vm.sortDirection).toBe('asc');
    });

    it('does not show loading any state', () => {
      expectLoadingState({ initial: false, nextPage: false });
    });
  });

  describe('when there is more than a page of vulnerabilities', () => {
    const vulnerabilities = generateVulnerabilities();

    beforeEach(() => {
      wrapper = createWrapper({
        data: () => ({
          vulnerabilities,
          pageInfo: {
            hasNextPage: true,
          },
        }),
      });
    });

    it('should render the observer component', () => {
      expect(findIntersectionObserver().exists()).toBe(true);
    });

    describe('when the filter is changed', () => {
      it('it should not render the observer component', async () => {
        await wrapper.setProps({ filters: {} });

        expect(findIntersectionObserver().exists()).toBe(false);
      });
    });
  });

  describe('when the query is loading and there is another page', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        loading: true,
        data: () => ({
          vulnerabilities: generateVulnerabilities(),
          pageInfo: {
            hasNextPage: true,
          },
        }),
      });
    });

    it('should render the observer component', () => {
      expect(findIntersectionObserver().exists()).toBe(true);
    });

    it('should render the next page loading spinner', () => {
      expectLoadingState({ nextPage: true });
    });
  });

  describe('when filter or sort is changed', () => {
    beforeEach(() => {
      wrapper = createWrapper({ loading: true });
    });

    it('should show the initial loading state when the filter is changed', async () => {
      await wrapper.setProps({ filter: {} });

      expectLoadingState({ initial: true });
    });

    it('should show the initial loading state when the sort is changed', () => {
      findVulnerabilities().vm.$emit('sort-changed', {
        sortBy: 'description',
        sortDesc: false,
      });

      expectLoadingState({ initial: true });
    });
  });
});
