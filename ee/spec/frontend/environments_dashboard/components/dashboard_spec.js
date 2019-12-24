import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { GlButton, GlModal } from '@gitlab/ui';
import createStore from 'ee/vue_shared/dashboards/store/index';
import state from 'ee/vue_shared/dashboards/store/state';
import component from 'ee/environments_dashboard/components/dashboard/dashboard.vue';
import ProjectHeader from 'ee/environments_dashboard/components/dashboard/project_header.vue';
import Environment from 'ee/environments_dashboard/components/dashboard/environment.vue';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';

import environment from './mock_environment.json';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('dashboard', () => {
  const Component = localVue.extend(component);
  let actionSpies;
  const store = createStore();
  let wrapper;
  let propsData;

  beforeEach(() => {
    actionSpies = {
      addProjectsToDashboard: jest.fn(),
      clearSearchResults: jest.fn(),
      setSearchQuery: jest.fn(),
      fetchSearchResults: jest.fn(),
      removeProject: jest.fn(),
      toggleSelectedProject: jest.fn(),
      fetchNextPage: jest.fn(),
      fetchProjects: jest.fn(),
    };
    propsData = {
      addPath: 'mock-addPath',
      listPath: 'mock-listPath',
      emptyDashboardSvgPath: '/assets/illustrations/operations-dashboard_empty.svg',
      emptyDashboardHelpPath: '/help/user/operations_dashboard/index.html',
    };

    wrapper = shallowMount(Component, {
      propsData,
      localVue,
      store,
      methods: {
        ...actionSpies,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    store.replaceState(state());
  });

  it('should match the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders the dashboard title', () => {
    expect(wrapper.find('.js-dashboard-title').text()).toBe('Environments Dashboard');
  });

  describe('add projects button', () => {
    let button;

    beforeEach(() => {
      button = wrapper.find(GlButton);
    });

    it('is labelled correctly', () => {
      expect(button.text()).toBe('Add projects');
    });
  });

  describe('wrapped components', () => {
    beforeEach(() => {
      store.state.projects = [
        {
          id: 0,
          name: 'test',
          namespace: { name: 'test', id: 0 },
          environments: [{ ...environment, id: 0 }, environment],
        },
        { id: 1, name: 'test', namespace: { name: 'test', id: 0 }, environments: [environment] },
      ];
    });

    describe('project header', () => {
      it('should have one project header per project', () => {
        const headers = wrapper.findAll(ProjectHeader);
        expect(headers.length).toBe(2);
      });

      it('should remove a project if it emits `remove`', () => {
        const header = wrapper.find(ProjectHeader);
        header.vm.$emit('remove');
        expect(actionSpies.removeProject).toHaveBeenCalled();
      });
    });

    describe('environment component', () => {
      it('should have one environment component per environment', () => {
        const environments = wrapper.findAll(Environment);
        expect(environments.length).toBe(3);
      });
    });

    describe('project selector modal', () => {
      beforeEach(() => {
        wrapper.find(GlButton).trigger('click');
        return wrapper.vm.$nextTick();
      });

      it('should fire the add projects action on ok', () => {
        wrapper.find(GlModal).vm.$emit('ok');
        expect(actionSpies.addProjectsToDashboard).toHaveBeenCalled();
      });

      it('should fire clear search when the modal is hidden', () => {
        wrapper.find(GlModal).vm.$emit('hidden');
        expect(actionSpies.clearSearchResults).toHaveBeenCalled();
      });

      it('should set the search query when searching', () => {
        wrapper.find(ProjectSelector).vm.$emit('searched', 'test');
        expect(actionSpies.setSearchQuery).toHaveBeenCalledWith('test');
      });

      it('should fetch query results when searching', () => {
        wrapper.find(ProjectSelector).vm.$emit('searched', 'test');
        expect(actionSpies.fetchSearchResults).toHaveBeenCalled();
      });

      it('should toggle a project when clicked', () => {
        wrapper.find(ProjectSelector).vm.$emit('projectClicked', { name: 'test', id: 1 });
        expect(actionSpies.toggleSelectedProject).toHaveBeenCalledWith({ name: 'test', id: 1 });
      });

      it('should fetch the next page when bottom is reached', () => {
        wrapper.find(ProjectSelector).vm.$emit('bottomReached');
        expect(actionSpies.fetchNextPage).toHaveBeenCalled();
      });

      it('should get the page info from the state', () => {
        store.state.pageInfo = { totalResults: 100 };
        expect(wrapper.find(ProjectSelector).props('totalResults')).toBe(100);
      });
    });
  });
});
