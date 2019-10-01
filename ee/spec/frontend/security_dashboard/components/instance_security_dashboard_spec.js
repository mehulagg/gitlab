import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import InstanceSecurityDashboard from 'ee/security_dashboard/components/instance_security_dashboard.vue';
import SecurityDashboard from 'ee/security_dashboard/components/app.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

const dashboardDocumentation = '/help/docs';
const emptyStateSvgPath = '/svgs/empty.svg';
const emptyDashboardStateSvgPath = '/svgs/empty-dash.svg';
const projectsEndpoint = '/projects';
const vulnerabilitiesEndpoint = '/vulnerabilities';
const vulnerabilitiesCountEndpoint = '/vulnerabilities_summary';
const vulnerabilitiesHistoryEndpoint = '/vulnerabilities_history';
const vulnerabilityFeedbackHelpPath = '/vulnerabilities_feedback_help';

describe('Instance Security Dashboard component', () => {
  let store;
  let wrapper;

  const factory = ({ projects = [], isInitialized = false } = {}) => {
    store = new Vuex.Store({
      modules: {
        projects: {
          namespaced: true,
          actions: {
            fetchProjects() {},
            setProjectsEndpoint() {},
          },
          state: {
            isInitialized,
            projects,
          },
        },
      },
    });
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(InstanceSecurityDashboard, {
      localVue,
      store,
      sync: false,
      propsData: {
        dashboardDocumentation,
        emptyStateSvgPath,
        emptyDashboardStateSvgPath,
        projectsEndpoint,
        vulnerabilitiesEndpoint,
        vulnerabilitiesCountEndpoint,
        vulnerabilitiesHistoryEndpoint,
        vulnerabilityFeedbackHelpPath,
      },
    });
  };

  const findProjectSelectorToggleButton = () => wrapper.find('.js-project-selector-toggle');

  const clickProjectSelectorToggleButton = () => {
    findProjectSelectorToggleButton().vm.$emit('click');

    return wrapper.vm.$nextTick();
  };

  const expectLoadingState = () => {
    expect(findProjectSelectorToggleButton().exists()).toBe(false);
    expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    expect(wrapper.find(SecurityDashboard).exists()).toBe(false);
  };

  const expectEmptyState = () => {
    expect(findProjectSelectorToggleButton().exists()).toBe(true);
    expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    expect(wrapper.find(SecurityDashboard).exists()).toBe(false);
  };

  const expectDashboardState = () => {
    expect(findProjectSelectorToggleButton().exists()).toBe(true);
    expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);

    const dashboard = wrapper.find(SecurityDashboard);
    expect(dashboard.exists()).toBe(true);
    expect(dashboard.props()).toEqual(
      expect.objectContaining({
        dashboardDocumentation,
        emptyStateSvgPath: emptyDashboardStateSvgPath,
        projectsEndpoint,
        vulnerabilitiesEndpoint,
        vulnerabilitiesCountEndpoint,
        vulnerabilitiesHistoryEndpoint,
        vulnerabilityFeedbackHelpPath,
      }),
    );
  };

  const expectProjectSelectorState = () => {
    expect(findProjectSelectorToggleButton().exists()).toBe(true);
    expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    expect(wrapper.find(SecurityDashboard).exists()).toBe(false);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on creation', () => {
    beforeEach(() => {
      factory();
    });

    it('dispatches the expected actions', () => {
      expect(store.dispatch.mock.calls).toEqual([
        ['projects/setProjectsEndpoint', projectsEndpoint],
        ['projects/fetchProjects', undefined],
      ]);
    });

    it('displays the loading spinner', () => {
      expectLoadingState();
    });
  });

  describe('given there are no projects', () => {
    beforeEach(() => {
      factory({ isInitialized: true });
    });

    it('renders the empty state', () => {
      expectEmptyState();
    });

    describe('after clicking the project selector toggle button', () => {
      beforeEach(clickProjectSelectorToggleButton);

      it('renders the project selector', () => {
        expectProjectSelectorState();
      });
    });
  });

  describe('given there are projects', () => {
    beforeEach(() => {
      factory({ projects: [{ name: 'foo', id: 1 }], isInitialized: true });
    });

    it('renders the security dashboard', () => {
      expectDashboardState();
    });

    describe('after clicking the project selector toggle button', () => {
      beforeEach(clickProjectSelectorToggleButton);

      it('renders the project selector', () => {
        expectProjectSelectorState();
      });
    });
  });
});
