import { GlTab } from '@gitlab/ui';
import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import UnscannedProjects from 'ee/security_dashboard/components/unscanned_projects.vue';
import TabContent from 'ee/security_dashboard/components/unscanned_projects_tab_content.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('UnscannedProjects component', () => {
  let wrapper;

  const defaultPropsData = { endpoint: 'foo/bar/endpoint', helpPath: 'foo/bar/help' };

  const defaultState = {
    isLoading: false,
    projects: [],
  };

  const defaultGetters = {
    outdatedProjects: () => [],
    untestedProjects: () => [],
    outdatedProjectsCount: () => 1,
    untestedProjectsCount: () => 1,
  };

  const defaultActions = {
    fetchUnscannedProjects: jest.fn(),
  };

  const factory = ({ getters = {}, propsData = {}, state = {} } = {}) => {
    const store = new Vuex.Store({
      modules: {
        unscannedProjects: {
          namespaced: true,
          actions: defaultActions,
          getters: { ...defaultGetters, ...getters },
          state: { ...defaultState, ...state },
        },
      },
    });

    wrapper = mount(UnscannedProjects, {
      propsData: { ...defaultPropsData, ...propsData },
      store,
      localVue,
    });
  };

  const outdatedProjectsTab = () => wrapper.find({ ref: 'outdatedProjectsTab' });
  const untestedProjectsTab = () => wrapper.find({ ref: 'untestedProjectsTab' });
  const outdatedProjectsTabContent = () => outdatedProjectsTab().find(TabContent);
  const untestedProjectsTabContent = () => untestedProjectsTab().find(TabContent);
  const outdatedProjectsCount = () => wrapper.find({ ref: 'outdatedProjectsCount' });
  const untestedProjectsCount = () => wrapper.find({ ref: 'untestedProjectsCount' });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('lifecycle hooks', () => {
    it('fetches projects from the given endpoint when the component is created', () => {
      factory();

      expect(defaultActions.fetchUnscannedProjects).toHaveBeenCalledTimes(1);
      expect(defaultActions.fetchUnscannedProjects.mock.calls[0][1]).toBe(
        defaultPropsData.endpoint,
      );
    });
  });

  describe('header', () => {
    it.each`
      helpPath           | description
      ${'/foo/bar/help'} | ${'not empty'}
      ${null}            | ${'empty'}
    `('matches the snapshot when the "helpPath" prop is $description', ({ helpPath }) => {
      factory({ propsData: { helpPath } });

      expect(wrapper.find('header').element).toMatchSnapshot();
    });
  });

  describe('tab buttons', () => {
    it('shows a tab-button for projects which have outdated security scanning', () => {
      factory();

      expect(outdatedProjectsTab().is(GlTab)).toBe(true);
    });

    it.each`
      type          | projectsCount
      ${'outdated'} | ${outdatedProjectsCount}
      ${'untested'} | ${untestedProjectsCount}
    `(`shows a count of $type projects`, ({ type, projectsCount }) => {
      factory({
        getters: {
          [`${type}ProjectsCount`]: () => 99,
        },
      });

      return wrapper.vm.$nextTick().then(() => {
        expect(projectsCount().text()).toContain(99);
      });
    });

    it('shows a tab-button for projects which have no security scanning configured', () => {
      factory();

      expect(untestedProjectsTab().is(GlTab)).toBe(true);
    });
  });

  describe('tab content', () => {
    beforeEach(factory);

    it.each`
      type          | tabContent
      ${'outdated'} | ${outdatedProjectsTabContent}
      ${'untested'} | ${untestedProjectsTabContent}
    `(
      'passes the "isLoading" prop to the $type projects tab-content component',
      ({ tabContent }) => {
        expect(tabContent().props('isLoading')).toBe(false);

        factory({ state: { isLoading: true } });

        return wrapper.vm.$nextTick(() => {
          expect(tabContent().props('isLoading')).toBe(true);
        });
      },
    );

    it.each`
      type          | tabContent
      ${'outdated'} | ${outdatedProjectsTabContent}
      ${'untested'} | ${untestedProjectsTabContent}
    `(
      'passes the "isEmpty" prop to the $type projects tab-content component',
      ({ type, tabContent }) => {
        expect(tabContent().props('isEmpty')).toBe(false);

        factory({ getters: { [`${type}ProjectsCount`]: () => 0 } });

        return wrapper.vm.$nextTick(() => {
          expect(tabContent().props('isEmpty')).toBe(true);
        });
      },
    );

    it('shows a list of outdated projects', () => {
      factory({
        getters: {
          outdatedProjects: () => [
            {
              description: 'Outdated Projects Group 1',
              projects: [{ fullName: 'Outdated Project One', fullPath: '/outdated-project-1' }],
            },
            {
              description: 'Outdated Projects Group 2',
              projects: [{ fullName: 'Outdated Project Two', fullPath: '/outdated-project-2' }],
            },
          ],
        },
      });

      expect(outdatedProjectsTabContent().element).toMatchSnapshot();
    });

    it('shows a list of untested projects', () => {
      factory({
        getters: {
          untestedProjects: () => [
            { fullName: 'Untested Project One', fullPath: '/untested-1' },
            { fullName: 'Untested Project Two', fullPath: '/untested-2' },
          ],
        },
      });

      expect(untestedProjectsTabContent().element).toMatchSnapshot();
    });
  });
});
