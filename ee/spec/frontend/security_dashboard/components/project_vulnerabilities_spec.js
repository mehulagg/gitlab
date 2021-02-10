import { GlAlert, GlIntersectionObserver, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ProjectVulnerabilitiesApp from 'ee/security_dashboard/components/project_vulnerabilities.vue';
import VulnerabilityList from 'ee/security_dashboard/components/vulnerability_list.vue';
import { generateVulnerabilities } from './mock_data';

describe('Vulnerabilities app component', () => {
  let wrapper;
  const apolloMock = {
    queries: { vulnerabilities: { loading: true } },
  };

  const createWrapper = ({ props = {}, $apollo = apolloMock } = {}, options = {}) => {
    wrapper = shallowMount(ProjectVulnerabilitiesApp, {
      provide: {
        projectFullPath: '#',
      },
      propsData: {
        dashboardDocumentation: '#',
        emptyStateSvgPath: '#',
        ...props,
      },
      mocks: {
        $apollo,
        fetchNextPage: () => {},
      },
      ...options,
    });
  };

  const findIntersectionObserver = () => wrapper.find(GlIntersectionObserver);
  const findAlert = () => wrapper.find(GlAlert);
  const findVulnerabilityList = () => wrapper.find(VulnerabilityList);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  const expectLoadingStates = (isInitialState, isNextPageState) => {
    expect(findVulnerabilityList().props('isLoading')).toBe(isInitialState);
    expect(findLoadingIcon().exists()).toBe(isNextPageState);
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when the vulnerabilities are loading', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('should show the initial loading state', () => {
      expectLoadingStates(true, false);
    });
  });

  describe('with some vulnerabilities', () => {
    let vulnerabilities;

    beforeEach(() => {
      createWrapper();

      vulnerabilities = generateVulnerabilities();
      wrapper.setData({ vulnerabilities });
    });

    it('should not show any loading state', () => {
      expectLoadingStates(false, false);
    });

    it('should pass the vulnerabilities to the vulnerabilities list', () => {
      expect(findVulnerabilityList().props().vulnerabilities).toEqual(vulnerabilities);
    });

    it('should not render the observer component', () => {
      expect(findIntersectionObserver().exists()).toBe(false);
    });

    it('should not render the alert', () => {
      expect(findAlert().exists()).toBe(false);
    });

    it('defaults to severity column for sorting', () => {
      expect(wrapper.vm.sortBy).toBe('severity');
    });

    it('defaults to desc as sorting direction', () => {
      expect(wrapper.vm.sortDirection).toBe('desc');
    });

    it('handles sorting', () => {
      findVulnerabilityList().vm.$emit('sort-changed', {
        sortBy: 'description',
        sortDesc: false,
      });

      expect(wrapper.vm.sortBy).toBe('description');
      expect(wrapper.vm.sortDirection).toBe('asc');
    });
  });

  describe('with more than a page of vulnerabilities', () => {
    let vulnerabilities;

    beforeEach(() => {
      createWrapper();

      vulnerabilities = generateVulnerabilities();
      wrapper.setData({
        vulnerabilities,
        pageInfo: {
          hasNextPage: true,
        },
      });
    });

    it('should render the observer component', () => {
      expect(findIntersectionObserver().exists()).toBe(true);
    });

    it('should render the next page loading spinner', () => {
      expectLoadingStates(false, true);
    });
  });

  describe(`when there's an error loading vulnerabilities`, () => {
    beforeEach(() => {
      createWrapper();
      wrapper.setData({ errorLoadingVulnerabilities: true });
    });

    it('should render the alert', () => {
      expect(findAlert().exists()).toBe(true);
    });
  });

  describe('when filter or sort is changed', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('should show the initial loading state when the filter is changed', () => {
      wrapper.setProps({ filter: {} });

      expectLoadingStates(true, false);
    });

    it('should show the initial loading state when the sort is changed', () => {
      findVulnerabilityList().vm.$emit('sort-changed', {
        sortBy: 'description',
        sortDesc: false,
      });

      expectLoadingStates(true, false);
    });
  });

  describe('security scanners', () => {
    const notEnabledScannersHelpPath = '#not-enabled';
    const noPipelineRunScannersHelpPath = '#no-pipeline';

    beforeEach(() => {
      createWrapper({
        props: { notEnabledScannersHelpPath, noPipelineRunScannersHelpPath },
      });
    });

    it('should pass the security scanners to the vulnerability list', () => {
      const securityScanners = {
        enabled: ['SAST', 'DAST', 'API_FUZZING', 'COVERAGE_FUZZING'],
        pipelineRun: ['SAST', 'DAST', 'API_FUZZING', 'COVERAGE_FUZZING'],
      };

      wrapper.setData({ securityScanners });

      expect(findVulnerabilityList().props().securityScanners).toEqual(securityScanners);
    });
  });
});
