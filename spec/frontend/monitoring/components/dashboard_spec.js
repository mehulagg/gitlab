import { shallowMount, mount } from '@vue/test-utils';
import Tracking from '~/tracking';
import { ESC_KEY, ESC_KEY_IE11 } from '~/lib/utils/keys';
import { GlModal, GlButton } from '@gitlab/ui';
import { objectToQuery } from '~/lib/utils/url_utility';
import VueDraggable from 'vuedraggable';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { dashboardEmptyStates, metricStates } from '~/monitoring/constants';
import Dashboard from '~/monitoring/components/dashboard.vue';

import DashboardHeader from '~/monitoring/components/dashboard_header.vue';
import CustomMetricsFormFields from '~/custom_metrics/components/custom_metrics_form_fields.vue';
import EmptyState from '~/monitoring/components/empty_state.vue';
import GroupEmptyState from '~/monitoring/components/group_empty_state.vue';
import DashboardPanel from '~/monitoring/components/dashboard_panel.vue';
import GraphGroup from '~/monitoring/components/graph_group.vue';
import LinksSection from '~/monitoring/components/links_section.vue';
import { createStore } from '~/monitoring/stores';
import * as types from '~/monitoring/stores/mutation_types';
import {
  setupAllDashboards,
  setupStoreWithDashboard,
  setMetricResult,
  setupStoreWithData,
  setupStoreWithDataForPanelCount,
  setupStoreWithLinks,
} from '../store_utils';
import { dashboardGitResponse, storeVariables } from '../mock_data';
import {
  metricsDashboardViewModel,
  metricsDashboardPanelCount,
  dashboardProps,
} from '../fixture_data';
import createFlash from '~/flash';
import { TEST_HOST } from 'helpers/test_constants';

jest.mock('~/flash');

describe('Dashboard', () => {
  let store;
  let wrapper;
  let mock;

  const findDashboardHeader = () => wrapper.find(DashboardHeader);

  const createShallowWrapper = (props = {}, options = {}) => {
    wrapper = shallowMount(Dashboard, {
      propsData: { ...dashboardProps, ...props },
      store,
      stubs: {
        DashboardHeader,
      },
      ...options,
    });
  };

  const createMountedWrapper = (props = {}, options = {}) => {
    wrapper = mount(Dashboard, {
      propsData: { ...dashboardProps, ...props },
      store,
      stubs: {
        'graph-group': true,
        'dashboard-panel': true,
        'dashboard-header': DashboardHeader,
      },
      ...options,
    });
  };

  beforeEach(() => {
    store = createStore();
    mock = new MockAdapter(axios);
    jest.spyOn(store, 'dispatch').mockResolvedValue();
  });

  afterEach(() => {
    mock.restore();
    if (store.dispatch.mockReset) {
      store.dispatch.mockReset();
    }
  });

  describe('request information to the server', () => {
    it('calls to set time range and fetch data', () => {
      createShallowWrapper({ hasMetrics: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(store.dispatch).toHaveBeenCalledWith(
          'monitoringDashboard/setTimeRange',
          expect.any(Object),
        );

        expect(store.dispatch).toHaveBeenCalledWith('monitoringDashboard/fetchData', undefined);
      });
    });

    it('shows up a loading state', () => {
      store.state.monitoringDashboard.emptyState = dashboardEmptyStates.LOADING;

      createShallowWrapper({ hasMetrics: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(EmptyState).exists()).toBe(true);
        expect(wrapper.find(EmptyState).props('selectedState')).toBe(dashboardEmptyStates.LOADING);
      });
    });

    it('hides the group panels when showPanels is false', () => {
      createMountedWrapper({ hasMetrics: true, showPanels: false });

      setupStoreWithData(store);

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.vm.emptyState).toBeNull();
        expect(wrapper.findAll('.prometheus-panel')).toHaveLength(0);
      });
    });

    it('fetches the metrics data with proper time window', () => {
      createMountedWrapper({ hasMetrics: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(store.dispatch).toHaveBeenCalledWith('monitoringDashboard/fetchData', undefined);
        expect(store.dispatch).toHaveBeenCalledWith(
          'monitoringDashboard/setTimeRange',
          expect.objectContaining({ duration: { seconds: 28800 } }),
        );
      });
    });
  });

  describe('panel containers layout', () => {
    const findPanelLayoutWrapperAt = index => {
      return wrapper
        .find(GraphGroup)
        .findAll('[data-testid="dashboard-panel-layout-wrapper"]')
        .at(index);
    };

    beforeEach(() => {
      createMountedWrapper({ hasMetrics: true });

      return wrapper.vm.$nextTick();
    });

    describe('when the graph group has an even number of panels', () => {
      it('2 panels - all panel wrappers take half width of their parent', () => {
        setupStoreWithDataForPanelCount(store, 2);

        wrapper.vm.$nextTick(() => {
          expect(findPanelLayoutWrapperAt(0).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(1).classes('col-lg-6')).toBe(true);
        });
      });

      it('4 panels - all panel wrappers take half width of their parent', () => {
        setupStoreWithDataForPanelCount(store, 4);

        wrapper.vm.$nextTick(() => {
          expect(findPanelLayoutWrapperAt(0).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(1).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(2).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(3).classes('col-lg-6')).toBe(true);
        });
      });
    });

    describe('when the graph group has an odd number of panels', () => {
      it('1 panel - panel wrapper does not take half width of its parent', () => {
        setupStoreWithDataForPanelCount(store, 1);

        wrapper.vm.$nextTick(() => {
          expect(findPanelLayoutWrapperAt(0).classes('col-lg-6')).toBe(false);
        });
      });

      it('3 panels - all panels but last take half width of their parents', () => {
        setupStoreWithDataForPanelCount(store, 3);

        wrapper.vm.$nextTick(() => {
          expect(findPanelLayoutWrapperAt(0).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(1).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(2).classes('col-lg-6')).toBe(false);
        });
      });

      it('5 panels - all panels but last take half width of their parents', () => {
        setupStoreWithDataForPanelCount(store, 5);

        wrapper.vm.$nextTick(() => {
          expect(findPanelLayoutWrapperAt(0).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(1).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(2).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(3).classes('col-lg-6')).toBe(true);
          expect(findPanelLayoutWrapperAt(4).classes('col-lg-6')).toBe(false);
        });
      });
    });
  });

  describe('dashboard validation warning', () => {
    it('displays a warning if there are validation warnings', () => {
      createMountedWrapper({ hasMetrics: true });

      store.commit(
        `monitoringDashboard/${types.RECEIVE_DASHBOARD_VALIDATION_WARNINGS_SUCCESS}`,
        true,
      );

      return wrapper.vm.$nextTick().then(() => {
        expect(createFlash).toHaveBeenCalled();
      });
    });

    it('does not display a warning if there are no validation warnings', () => {
      createMountedWrapper({ hasMetrics: true });

      store.commit(
        `monitoringDashboard/${types.RECEIVE_DASHBOARD_VALIDATION_WARNINGS_SUCCESS}`,
        false,
      );

      return wrapper.vm.$nextTick().then(() => {
        expect(createFlash).not.toHaveBeenCalled();
      });
    });
  });

  describe('when the URL contains a reference to a panel', () => {
    let location;

    const setSearch = search => {
      window.location = { ...location, search };
    };

    beforeEach(() => {
      location = window.location;
      delete window.location;
    });

    afterEach(() => {
      window.location = location;
    });

    it('when the URL points to a panel it expands', () => {
      const panelGroup = metricsDashboardViewModel.panelGroups[0];
      const panel = panelGroup.panels[0];

      setSearch(
        objectToQuery({
          group: panelGroup.group,
          title: panel.title,
          y_label: panel.y_label,
        }),
      );

      createMountedWrapper({ hasMetrics: true });
      setupStoreWithData(store);

      return wrapper.vm.$nextTick().then(() => {
        expect(store.dispatch).toHaveBeenCalledWith('monitoringDashboard/setExpandedPanel', {
          group: panelGroup.group,
          panel: expect.objectContaining({
            title: panel.title,
            y_label: panel.y_label,
          }),
        });
      });
    });

    it('when the URL does not link to any panel, no panel is expanded', () => {
      setSearch('');

      createMountedWrapper({ hasMetrics: true });
      setupStoreWithData(store);

      return wrapper.vm.$nextTick().then(() => {
        expect(store.dispatch).not.toHaveBeenCalledWith(
          'monitoringDashboard/setExpandedPanel',
          expect.anything(),
        );
      });
    });

    it('when the URL points to an incorrect panel it shows an error', () => {
      const panelGroup = metricsDashboardViewModel.panelGroups[0];
      const panel = panelGroup.panels[0];

      setSearch(
        objectToQuery({
          group: panelGroup.group,
          title: 'incorrect',
          y_label: panel.y_label,
        }),
      );

      createMountedWrapper({ hasMetrics: true });
      setupStoreWithData(store);

      return wrapper.vm.$nextTick().then(() => {
        expect(createFlash).toHaveBeenCalled();
        expect(store.dispatch).not.toHaveBeenCalledWith(
          'monitoringDashboard/setExpandedPanel',
          expect.anything(),
        );
      });
    });
  });

  describe('when the panel is expanded', () => {
    let group;
    let panel;

    const expandPanel = (mockGroup, mockPanel) => {
      store.commit(`monitoringDashboard/${types.SET_EXPANDED_PANEL}`, {
        group: mockGroup,
        panel: mockPanel,
      });
    };

    beforeEach(() => {
      setupStoreWithData(store);

      const { panelGroups } = store.state.monitoringDashboard.dashboard;
      group = panelGroups[0].group;
      [panel] = panelGroups[0].panels;

      jest.spyOn(window.history, 'pushState').mockImplementation();
    });

    afterEach(() => {
      window.history.pushState.mockRestore();
    });

    it('URL is updated with panel parameters', () => {
      createMountedWrapper({ hasMetrics: true });
      expandPanel(group, panel);

      const expectedSearch = objectToQuery({
        group,
        title: panel.title,
        y_label: panel.y_label,
      });

      return wrapper.vm.$nextTick(() => {
        expect(window.history.pushState).toHaveBeenCalledTimes(1);
        expect(window.history.pushState).toHaveBeenCalledWith(
          expect.anything(), // state
          expect.any(String), // document title
          expect.stringContaining(`${expectedSearch}`),
        );
      });
    });

    it('URL is updated with panel parameters and custom dashboard', () => {
      const dashboard = 'dashboard.yml';

      store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
        currentDashboard: dashboard,
      });
      createMountedWrapper({ hasMetrics: true });
      expandPanel(group, panel);

      const expectedSearch = objectToQuery({
        dashboard,
        group,
        title: panel.title,
        y_label: panel.y_label,
      });

      return wrapper.vm.$nextTick(() => {
        expect(window.history.pushState).toHaveBeenCalledTimes(1);
        expect(window.history.pushState).toHaveBeenCalledWith(
          expect.anything(), // state
          expect.any(String), // document title
          expect.stringContaining(`${expectedSearch}`),
        );
      });
    });

    it('URL is updated with no parameters', () => {
      expandPanel(group, panel);
      createMountedWrapper({ hasMetrics: true });
      expandPanel(null, null);

      return wrapper.vm.$nextTick(() => {
        expect(window.history.pushState).toHaveBeenCalledTimes(1);
        expect(window.history.pushState).toHaveBeenCalledWith(
          expect.anything(), // state
          expect.any(String), // document title
          expect.not.stringMatching(/group|title|y_label/), // no panel params
        );
      });
    });
  });

  describe('when all panels in the first group are loading', () => {
    const findGroupAt = i => wrapper.findAll(GraphGroup).at(i);

    beforeEach(() => {
      setupStoreWithDashboard(store);

      const { panels } = store.state.monitoringDashboard.dashboard.panelGroups[0];
      panels.forEach(({ metrics }) => {
        store.commit(`monitoringDashboard/${types.REQUEST_METRIC_RESULT}`, {
          metricId: metrics[0].metricId,
        });
      });

      createShallowWrapper();

      return wrapper.vm.$nextTick();
    });

    it('a loading icon appears in the first group', () => {
      expect(findGroupAt(0).props('isLoading')).toBe(true);
    });

    it('a loading icon does not appear in the second group', () => {
      expect(findGroupAt(1).props('isLoading')).toBe(false);
    });
  });

  describe('when all requests have been commited by the store', () => {
    beforeEach(() => {
      store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
        currentEnvironmentName: 'production',
        currentDashboard: dashboardGitResponse[0].path,
        projectPath: TEST_HOST,
      });
      createMountedWrapper({ hasMetrics: true });
      setupStoreWithData(store);

      return wrapper.vm.$nextTick();
    });

    it('it does not show loading icons in any group', () => {
      setupStoreWithData(store);

      wrapper.vm.$nextTick(() => {
        wrapper.findAll(GraphGroup).wrappers.forEach(groupWrapper => {
          expect(groupWrapper.props('isLoading')).toBe(false);
        });
      });
    });
  });

  describe('star dashboards', () => {
    const findToggleStar = () => findDashboardHeader().find({ ref: 'toggleStarBtn' });

    beforeEach(() => {
      createShallowWrapper();
      setupAllDashboards(store);
    });

    it('toggle star button is shown', () => {
      expect(findToggleStar().exists()).toBe(true);
      expect(findToggleStar().props('disabled')).toBe(false);
    });

    it('toggle star button is disabled when starring is taking place', () => {
      store.commit(`monitoringDashboard/${types.REQUEST_DASHBOARD_STARRING}`);

      return wrapper.vm.$nextTick(() => {
        expect(findToggleStar().exists()).toBe(true);
        expect(findToggleStar().props('disabled')).toBe(true);
      });
    });

    describe('when the dashboard list is loaded', () => {
      // Tooltip element should wrap directly
      const getToggleTooltip = () => findToggleStar().element.parentElement.getAttribute('title');

      beforeEach(() => {
        setupAllDashboards(store);
        jest.spyOn(store, 'dispatch');
      });

      it('dispatches a toggle star action', () => {
        findToggleStar().vm.$emit('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(store.dispatch).toHaveBeenCalledWith(
            'monitoringDashboard/toggleStarredValue',
            undefined,
          );
        });
      });

      describe('when dashboard is not starred', () => {
        beforeEach(() => {
          store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
            currentDashboard: dashboardGitResponse[0].path,
          });
          return wrapper.vm.$nextTick();
        });

        it('toggle star button shows "Star dashboard"', () => {
          expect(getToggleTooltip()).toBe('Star dashboard');
        });

        it('toggle star button shows  an unstarred state', () => {
          expect(findToggleStar().attributes('icon')).toBe('star-o');
        });
      });

      describe('when dashboard is starred', () => {
        beforeEach(() => {
          store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
            currentDashboard: dashboardGitResponse[1].path,
          });
          return wrapper.vm.$nextTick();
        });

        it('toggle star button shows "Star dashboard"', () => {
          expect(getToggleTooltip()).toBe('Unstar dashboard');
        });

        it('toggle star button shows a starred state', () => {
          expect(findToggleStar().attributes('icon')).toBe('star');
        });
      });
    });
  });

  describe('variables section', () => {
    beforeEach(() => {
      createShallowWrapper({ hasMetrics: true });
      setupStoreWithData(store);
      store.state.monitoringDashboard.variables = storeVariables;
      return wrapper.vm.$nextTick();
    });

    it('shows the variables section', () => {
      expect(wrapper.vm.shouldShowVariablesSection).toBe(true);
    });
  });

  describe('links section', () => {
    beforeEach(() => {
      createShallowWrapper({ hasMetrics: true });
      setupStoreWithData(store);
      setupStoreWithLinks(store);

      return wrapper.vm.$nextTick();
    });

    it('shows the links section', () => {
      expect(wrapper.vm.shouldShowLinksSection).toBe(true);
      expect(wrapper.find(LinksSection)).toExist();
    });
  });

  describe('single panel expands to "full screen" mode', () => {
    const findExpandedPanel = () => wrapper.find({ ref: 'expandedPanel' });

    describe('when the panel is not expanded', () => {
      beforeEach(() => {
        createShallowWrapper({ hasMetrics: true });
        setupStoreWithData(store);
        return wrapper.vm.$nextTick();
      });

      it('expanded panel is not visible', () => {
        expect(findExpandedPanel().isVisible()).toBe(false);
      });

      it('can set a panel as expanded', () => {
        const panel = wrapper.findAll(DashboardPanel).at(1);

        jest.spyOn(store, 'dispatch');

        panel.vm.$emit('expand');

        const groupData = metricsDashboardViewModel.panelGroups[0];

        expect(store.dispatch).toHaveBeenCalledWith('monitoringDashboard/setExpandedPanel', {
          group: groupData.group,
          panel: expect.objectContaining({
            id: groupData.panels[0].id,
          }),
        });
      });
    });

    describe('when the panel is expanded', () => {
      let group;
      let panel;

      const mockKeyup = key => window.dispatchEvent(new KeyboardEvent('keyup', { key }));

      const MockPanel = {
        template: `<div><slot name="topLeft"/></div>`,
      };

      beforeEach(() => {
        createShallowWrapper({ hasMetrics: true }, { stubs: { DashboardPanel: MockPanel } });
        setupStoreWithData(store);

        const { panelGroups } = store.state.monitoringDashboard.dashboard;

        group = panelGroups[0].group;
        [panel] = panelGroups[0].panels;

        store.commit(`monitoringDashboard/${types.SET_EXPANDED_PANEL}`, {
          group,
          panel,
        });

        jest.spyOn(store, 'dispatch');

        return wrapper.vm.$nextTick();
      });

      it('displays a single panel and others are hidden', () => {
        const panels = wrapper.findAll(MockPanel);
        const visiblePanels = panels.filter(w => w.isVisible());

        expect(findExpandedPanel().isVisible()).toBe(true);
        // v-show for hiding panels is more performant than v-if
        // check for panels to be hidden.
        expect(panels.length).toBe(metricsDashboardPanelCount + 1);
        expect(visiblePanels.length).toBe(1);
      });

      it('sets a link to the expanded panel', () => {
        const searchQuery =
          '?dashboard=config%2Fprometheus%2Fcommon_metrics.yml&group=System%20metrics%20(Kubernetes)&title=Memory%20Usage%20(Total)&y_label=Total%20Memory%20Used%20(GB)';

        expect(findExpandedPanel().attributes('clipboard-text')).toEqual(
          expect.stringContaining(searchQuery),
        );
      });

      it('restores full dashboard by clicking `back`', () => {
        wrapper.find({ ref: 'goBackBtn' }).vm.$emit('click');

        expect(store.dispatch).toHaveBeenCalledWith(
          'monitoringDashboard/clearExpandedPanel',
          undefined,
        );
      });

      it('restores dashboard from full screen by typing the Escape key', () => {
        mockKeyup(ESC_KEY);
        expect(store.dispatch).toHaveBeenCalledWith(
          `monitoringDashboard/clearExpandedPanel`,
          undefined,
        );
      });

      it('restores dashboard from full screen by typing the Escape key on IE11', () => {
        mockKeyup(ESC_KEY_IE11);

        expect(store.dispatch).toHaveBeenCalledWith(
          `monitoringDashboard/clearExpandedPanel`,
          undefined,
        );
      });
    });
  });

  describe('when one of the metrics is missing', () => {
    beforeEach(() => {
      createShallowWrapper({ hasMetrics: true });

      setupStoreWithDashboard(store);
      setMetricResult({ store, result: [], panel: 2 });

      return wrapper.vm.$nextTick();
    });

    it('shows a group empty area', () => {
      const emptyGroup = wrapper.findAll({ ref: 'empty-group' });

      expect(emptyGroup).toHaveLength(1);
      expect(emptyGroup.is(GroupEmptyState)).toBe(true);
    });

    it('group empty area displays a NO_DATA state', () => {
      expect(
        wrapper
          .findAll({ ref: 'empty-group' })
          .at(0)
          .props('selectedState'),
      ).toEqual(metricStates.NO_DATA);
    });
  });

  describe('drag and drop function', () => {
    const findDraggables = () => wrapper.findAll(VueDraggable);
    const findEnabledDraggables = () => findDraggables().filter(f => !f.attributes('disabled'));
    const findDraggablePanels = () => wrapper.findAll('.js-draggable-panel');
    const findRearrangeButton = () => wrapper.find('.js-rearrange-button');

    beforeEach(() => {
      // call original dispatch
      store.dispatch.mockRestore();

      createShallowWrapper({ hasMetrics: true });
      setupStoreWithData(store);

      return wrapper.vm.$nextTick();
    });

    it('wraps vuedraggable', () => {
      expect(findDraggablePanels().exists()).toBe(true);
      expect(findDraggablePanels().length).toEqual(metricsDashboardPanelCount);
    });

    it('is disabled by default', () => {
      expect(findRearrangeButton().exists()).toBe(false);
      expect(findEnabledDraggables().length).toBe(0);
    });

    describe('when rearrange is enabled', () => {
      beforeEach(() => {
        wrapper.setProps({ rearrangePanelsAvailable: true });
        return wrapper.vm.$nextTick();
      });

      it('displays rearrange button', () => {
        expect(findRearrangeButton().exists()).toBe(true);
      });

      describe('when rearrange button is clicked', () => {
        const findFirstDraggableRemoveButton = () =>
          findDraggablePanels()
            .at(0)
            .find('.js-draggable-remove');

        beforeEach(() => {
          findRearrangeButton().vm.$emit('click');
          return wrapper.vm.$nextTick();
        });

        it('it enables draggables', () => {
          expect(findRearrangeButton().attributes('pressed')).toBeTruthy();
          expect(findEnabledDraggables()).toEqual(findDraggables());
        });

        it('metrics can be swapped', () => {
          const firstDraggable = findDraggables().at(0);
          const mockMetrics = [...metricsDashboardViewModel.panelGroups[0].panels];

          const firstTitle = mockMetrics[0].title;
          const secondTitle = mockMetrics[1].title;

          // swap two elements and `input` them
          [mockMetrics[0], mockMetrics[1]] = [mockMetrics[1], mockMetrics[0]];
          firstDraggable.vm.$emit('input', mockMetrics);

          return wrapper.vm.$nextTick(() => {
            const { panels } = wrapper.vm.dashboard.panelGroups[0];

            expect(panels[1].title).toEqual(firstTitle);
            expect(panels[0].title).toEqual(secondTitle);
          });
        });

        it('shows a remove button, which removes a panel', () => {
          expect(findFirstDraggableRemoveButton().isEmpty()).toBe(false);

          expect(findDraggablePanels().length).toEqual(metricsDashboardPanelCount);
          findFirstDraggableRemoveButton().trigger('click');

          return wrapper.vm.$nextTick(() => {
            expect(findDraggablePanels().length).toEqual(metricsDashboardPanelCount - 1);
          });
        });

        it('it disables draggables when clicked again', () => {
          findRearrangeButton().vm.$emit('click');
          return wrapper.vm.$nextTick(() => {
            expect(findRearrangeButton().attributes('pressed')).toBeFalsy();
            expect(findEnabledDraggables().length).toBe(0);
          });
        });
      });
    });
  });

  describe('cluster health', () => {
    beforeEach(() => {
      createShallowWrapper({ hasMetrics: true, showHeader: false });

      // all_dashboards is not defined in health dashboards
      store.commit(`monitoringDashboard/${types.SET_ALL_DASHBOARDS}`, undefined);
      return wrapper.vm.$nextTick();
    });

    it('hides dashboard header by default', () => {
      expect(wrapper.find({ ref: 'prometheusGraphsHeader' }).exists()).toEqual(false);
    });

    it('renders correctly', () => {
      expect(wrapper.isVueInstance()).toBe(true);
      expect(wrapper.exists()).toBe(true);
    });
  });

  describe('dashboard edit link', () => {
    const findEditLink = () => wrapper.find('.js-edit-link');

    beforeEach(() => {
      createShallowWrapper({ hasMetrics: true });

      setupAllDashboards(store);
      return wrapper.vm.$nextTick();
    });

    it('is not present for the overview dashboard', () => {
      expect(findEditLink().exists()).toBe(false);
    });

    it('is present for a custom dashboard, and links to its edit_path', () => {
      const dashboard = dashboardGitResponse[1];
      store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
        currentDashboard: dashboard.path,
      });

      return wrapper.vm.$nextTick().then(() => {
        expect(findEditLink().exists()).toBe(true);
        expect(findEditLink().attributes('href')).toBe(dashboard.project_blob_path);
      });
    });
  });

  describe('document title', () => {
    const originalTitle = 'Original Title';
    const overviewDashboardName = dashboardGitResponse[0].display_name;

    beforeEach(() => {
      document.title = originalTitle;
      createShallowWrapper({ hasMetrics: true });
    });

    afterAll(() => {
      document.title = '';
    });

    it('is prepended with the overview dashboard name by default', () => {
      setupAllDashboards(store);

      return wrapper.vm.$nextTick().then(() => {
        expect(document.title.startsWith(`${overviewDashboardName} · `)).toBe(true);
      });
    });

    it('is prepended with dashboard name if path is known', () => {
      const dashboard = dashboardGitResponse[1];
      const currentDashboard = dashboard.path;

      setupAllDashboards(store, currentDashboard);

      return wrapper.vm.$nextTick().then(() => {
        expect(document.title.startsWith(`${dashboard.display_name} · `)).toBe(true);
      });
    });

    it('is prepended with the overview dashboard name if path is not known', () => {
      setupAllDashboards(store, 'unknown/path');

      return wrapper.vm.$nextTick().then(() => {
        expect(document.title.startsWith(`${overviewDashboardName} · `)).toBe(true);
      });
    });

    it('is not modified when dashboard name is not provided', () => {
      const dashboard = { ...dashboardGitResponse[1], display_name: null };
      const currentDashboard = dashboard.path;

      store.commit(`monitoringDashboard/${types.SET_ALL_DASHBOARDS}`, [dashboard]);

      store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
        currentDashboard,
      });

      return wrapper.vm.$nextTick().then(() => {
        expect(document.title).toBe(originalTitle);
      });
    });
  });

  describe('external dashboard link', () => {
    beforeEach(() => {
      createMountedWrapper({
        hasMetrics: true,
        showPanels: false,
        showTimeWindowDropdown: false,
        externalDashboardUrl: '/mockUrl',
      });

      return wrapper.vm.$nextTick();
    });

    it('shows the link', () => {
      const externalDashboardButton = wrapper.find('.js-external-dashboard-link');

      expect(externalDashboardButton.exists()).toBe(true);
      expect(externalDashboardButton.is(GlButton)).toBe(true);
      expect(externalDashboardButton.text()).toContain('View full dashboard');
    });
  });

  describe('Clipboard text in panels', () => {
    const currentDashboard = dashboardGitResponse[1].path;
    const panelIndex = 1; // skip expanded panel

    const getClipboardTextFirstPanel = () =>
      wrapper
        .findAll(DashboardPanel)
        .at(panelIndex)
        .props('clipboardText');

    beforeEach(() => {
      setupStoreWithData(store);
      store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
        currentDashboard,
      });
      createShallowWrapper({ hasMetrics: true });

      return wrapper.vm.$nextTick();
    });

    it('contains a link to the dashboard', () => {
      const dashboardParam = `dashboard=${encodeURIComponent(currentDashboard)}`;

      expect(getClipboardTextFirstPanel()).toContain(dashboardParam);
      expect(getClipboardTextFirstPanel()).toContain(`group=`);
      expect(getClipboardTextFirstPanel()).toContain(`title=`);
      expect(getClipboardTextFirstPanel()).toContain(`y_label=`);
    });
  });

  describe('keyboard shortcuts', () => {
    const currentDashboard = dashboardGitResponse[1].path;
    const panelRef = 'dashboard-panel-response-metrics-aws-elb-4-1'; // skip expanded panel

    // While the recommendation in the documentation is to test
    // with a data-testid attribute, I want to make sure that
    // the dashboard panels have a ref attribute set.
    const getDashboardPanel = () => wrapper.find({ ref: panelRef });

    beforeEach(() => {
      setupStoreWithData(store);
      store.commit(`monitoringDashboard/${types.SET_INITIAL_STATE}`, {
        currentDashboard,
      });
      createShallowWrapper({ hasMetrics: true });

      wrapper.setData({ hoveredPanel: panelRef });

      return wrapper.vm.$nextTick();
    });

    it('contains a ref attribute inside a DashboardPanel component', () => {
      const dashboardPanel = getDashboardPanel();

      expect(dashboardPanel.exists()).toBe(true);
    });
  });

  describe('add custom metrics', () => {
    const findAddMetricButton = () => findDashboardHeader().find({ ref: 'addMetricBtn' });

    describe('when not available', () => {
      beforeEach(() => {
        createShallowWrapper({
          hasMetrics: true,
          customMetricsPath: '/endpoint',
        });
      });
      it('does not render add button on the dashboard', () => {
        expect(findAddMetricButton().exists()).toBe(false);
      });
    });

    describe('when available', () => {
      let origPage;
      beforeEach(done => {
        jest.spyOn(Tracking, 'event').mockReturnValue();
        createShallowWrapper({
          hasMetrics: true,
          customMetricsPath: '/endpoint',
        });
        setupStoreWithData(store);

        origPage = document.body.dataset.page;
        document.body.dataset.page = 'projects:environments:metrics';

        wrapper.vm.$nextTick(done);
      });
      afterEach(() => {
        document.body.dataset.page = origPage;
      });

      it('renders add button on the dashboard', () => {
        expect(findAddMetricButton()).toBeDefined();
      });

      it('uses modal for custom metrics form', () => {
        expect(wrapper.find(GlModal).exists()).toBe(true);
        expect(wrapper.find(GlModal).attributes().modalid).toBe('addMetric');
      });
      it('adding new metric is tracked', done => {
        const submitButton = wrapper
          .find(DashboardHeader)
          .find({ ref: 'submitCustomMetricsFormBtn' }).vm;
        wrapper.vm.$nextTick(() => {
          submitButton.$el.click();
          wrapper.vm.$nextTick(() => {
            expect(Tracking.event).toHaveBeenCalledWith(
              document.body.dataset.page,
              'click_button',
              {
                label: 'add_new_metric',
                property: 'modal',
                value: undefined,
              },
            );
            done();
          });
        });
      });

      it('renders custom metrics form fields', () => {
        expect(wrapper.find(CustomMetricsFormFields).exists()).toBe(true);
      });
    });
  });
});
