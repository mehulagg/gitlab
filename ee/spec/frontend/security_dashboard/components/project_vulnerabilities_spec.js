import { GlAlert, GlIntersectionObserver, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import ProjectVulnerabilitiesApp from 'ee/security_dashboard/components/project_vulnerabilities.vue';
import VulnerabilityList from 'ee/security_dashboard/components/vulnerability_list.vue';
import vulnerabilitiesQuery from 'ee/security_dashboard/graphql/queries/project_vulnerabilities.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { generateVulnerabilities } from './mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Vulnerabilities app component', () => {
  let wrapper;
  const apolloMock = {
    queries: { vulnerabilities: { loading: true } },
  };

  const createWrapper = ({ props = {}, $apollo = apolloMock } = {}, options = {}) => {
    wrapper = shallowMount(ProjectVulnerabilitiesApp, {
      provide: {
        projectFullPath: '#',
        hasJiraVulnerabilitiesIntegrationEnabled: false,
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

  const expectLoadingState = ({ initial = false, nextPage = false }) => {
    expect(findVulnerabilityList().props('isLoading')).toBe(initial);
    expect(findLoadingIcon().exists()).toBe(nextPage);
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
      expectLoadingState({ initial: true });
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
      expectLoadingState({ initial: false, nextPage: false });
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
      expectLoadingState({ nextPage: true });
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

      expectLoadingState({ initial: true });
    });

    it('should show the initial loading state when the sort is changed', () => {
      findVulnerabilityList().vm.$emit('sort-changed', {
        sortBy: 'description',
        sortDesc: false,
      });

      expectLoadingState({ initial: true });
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

  describe('filters prop', () => {
    const mockQuery = jest.fn().mockResolvedValue({
      data: {
        project: {
          vulnerabilities: {
            nodes: [],
            pageInfo: { startCursor: '', endCursor: '' },
          },
        },
      },
    });

    const createWrapperWithApollo = ({ query, filters }) => {
      wrapper = shallowMount(ProjectVulnerabilitiesApp, {
        localVue,
        apolloProvider: createMockApollo([[vulnerabilitiesQuery, query]]),
        propsData: { filters },
        provide: { groupFullPath: 'path' },
      });
    };

    it('does not run the query when filters is null', () => {
      createWrapperWithApollo({ query: mockQuery, filters: null });

      expect(mockQuery).not.toHaveBeenCalled();
    });

    it('runs query when filters is an object', () => {
      createWrapperWithApollo({ query: mockQuery, filters: {} });

      expect(mockQuery).toHaveBeenCalled();
    });
  });
});
