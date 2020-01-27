import Vue from 'vue';
import { GlDropdown, GlDropdownItem, GlSearchBoxByClick } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import EnvironmentLogs from 'ee/logs/components/environment_logs.vue';

import { createStore } from 'ee/logs/stores';
import { scrollDown } from '~/lib/utils/scroll_utils';
import {
  mockEnvName,
  mockEnvironments,
  mockPods,
  mockLogsResult,
  mockTrace,
  mockPodName,
  mockEnvironmentsEndpoint,
  mockDocumentationPath,
} from '../mock_data';

jest.mock('~/lib/utils/scroll_utils');

describe('EnvironmentLogs', () => {
  let EnvironmentLogsComponent;
  let store;
  let wrapper;
  let state;

  const propsData = {
    environmentName: mockEnvName,
    environmentsPath: mockEnvironmentsEndpoint,
    clusterApplicationsDocumentationPath: mockDocumentationPath,
  };

  const actionMocks = {
    setInitData: jest.fn(),
    showPodLogs: jest.fn(),
    showEnvironment: jest.fn(),
    fetchEnvironments: jest.fn(),
  };

  const updateControlBtnsMock = jest.fn();

  const findEnvironmentsDropdown = () => wrapper.find('.js-environments-dropdown');
  const findPodsDropdown = () => wrapper.find('.js-pods-dropdown');
  const findSearchBar = () => wrapper.find('.js-logs-search');
  const findTimeWindowDropdown = () => wrapper.find({ ref: 'time-window-dropdown' });

  const findLogControlButtons = () => wrapper.find({ name: 'log-control-buttons-stub' });
  const findLogTrace = () => wrapper.find('.js-log-trace');

  const mockSetInitData = () => {
    state.pods.options = mockPods;
    state.environments.current = mockEnvName;
    [state.pods.current] = state.pods.options;

    state.logs.isComplete = false;
    state.logs.lines = mockLogsResult;
  };

  const mockShowPodLogs = podName => {
    state.pods.options = mockPods;
    [state.pods.current] = podName;

    state.logs.isComplete = false;
    state.logs.lines = mockLogsResult;
  };

  const mockFetchEnvs = () => {
    state.environments.options = mockEnvironments;
  };

  const initWrapper = () => {
    wrapper = shallowMount(EnvironmentLogsComponent, {
      propsData,
      store,
      stubs: {
        LogControlButtons: {
          name: 'log-control-buttons-stub',
          template: '<div/>',
          methods: {
            update: updateControlBtnsMock,
          },
        },
      },
      methods: {
        ...actionMocks,
      },
    });
  };

  beforeEach(() => {
    store = createStore();
    state = store.state.environmentLogs;
    EnvironmentLogsComponent = Vue.extend(EnvironmentLogs);
  });

  afterEach(() => {
    actionMocks.setInitData.mockReset();
    actionMocks.showPodLogs.mockReset();
    actionMocks.fetchEnvironments.mockReset();

    if (wrapper) {
      wrapper.destroy();
    }
  });

  it('displays UI elements', () => {
    initWrapper();

    expect(wrapper.isVueInstance()).toBe(true);
    expect(wrapper.isEmpty()).toBe(false);

    // top bar
    expect(findEnvironmentsDropdown().is(GlDropdown)).toBe(true);
    expect(findPodsDropdown().is(GlDropdown)).toBe(true);
    expect(findLogControlButtons().exists()).toBe(true);

    expect(findSearchBar().exists()).toBe(true); // behind ff
    expect(findTimeWindowDropdown().exists()).toBe(true); // behind ff

    // log trace
    expect(findLogTrace().isEmpty()).toBe(false);

    // layout
    expect(wrapper.find('#environments-dropdown-fg').attributes('class')).toMatch('col-3 px-1');
    expect(wrapper.find('#pods-dropdown-fg').attributes('class')).toMatch('col-3 px-1');
  });

  it('mounted inits data', () => {
    initWrapper();

    expect(actionMocks.setInitData).toHaveBeenCalledTimes(1);
    expect(actionMocks.setInitData).toHaveBeenLastCalledWith({
      environmentName: mockEnvName,
      podName: null,
    });

    expect(actionMocks.fetchEnvironments).toHaveBeenCalledTimes(1);
    expect(actionMocks.fetchEnvironments).toHaveBeenLastCalledWith(mockEnvironmentsEndpoint);
  });

  describe('loading state', () => {
    beforeEach(() => {
      state.pods.options = [];

      state.logs.lines = [];
      state.logs.isLoading = true;

      state.environments.options = [];
      state.environments.isLoading = true;

      initWrapper();
    });

    it('displays a disabled environments dropdown', () => {
      expect(findEnvironmentsDropdown().attributes('disabled')).toEqual('true');
      expect(findEnvironmentsDropdown().findAll(GlDropdownItem).length).toBe(0);
    });

    it('displays a disabled pods dropdown', () => {
      expect(findPodsDropdown().attributes('disabled')).toEqual('true');
      expect(findPodsDropdown().findAll(GlDropdownItem).length).toBe(0);
    });

    it('does not update buttons state', () => {
      expect(updateControlBtnsMock).not.toHaveBeenCalled();
    });

    it('shows a logs trace', () => {
      expect(findLogTrace().text()).toBe('');
      expect(
        findLogTrace()
          .find('.js-build-loader-animation')
          .isVisible(),
      ).toBe(true);
    });
  });

  describe('ES enabled and legacy environment', () => {
    beforeEach(() => {
      state.pods.options = [];

      state.logs.lines = [];
      state.logs.isLoading = false;

      state.environments.options = mockEnvironments;
      state.environments.current = 'staging';
      state.environments.isLoading = false;

      gon.features = gon.features || {};
      gon.features.enableClusterApplicationElasticStack = true;

      initWrapper();
    });

    it('displays a disabled search bar', () => {
      expect(findSearchBar().exists()).toEqual(true);
      expect(findSearchBar().attributes('disabled')).toEqual('true');
    });
  });

  describe('state with data', () => {
    beforeEach(() => {
      actionMocks.setInitData.mockImplementation(mockSetInitData);
      actionMocks.showPodLogs.mockImplementation(mockShowPodLogs);
      actionMocks.fetchEnvironments.mockImplementation(mockFetchEnvs);

      gon.features = gon.features || {};
      gon.features.enableClusterApplicationElasticStack = true;

      initWrapper();
    });

    afterEach(() => {
      scrollDown.mockReset();
      updateControlBtnsMock.mockReset();

      actionMocks.setInitData.mockReset();
      actionMocks.showPodLogs.mockReset();
      actionMocks.fetchEnvironments.mockReset();
    });

    it('populates environments dropdown', () => {
      const items = findEnvironmentsDropdown().findAll(GlDropdownItem);
      expect(findEnvironmentsDropdown().props('text')).toBe(mockEnvName);
      expect(items.length).toBe(mockEnvironments.length);
      mockEnvironments.forEach((env, i) => {
        const item = items.at(i);
        expect(item.text()).toBe(env.name);
      });
    });

    it('populates pods dropdown', () => {
      const items = findPodsDropdown().findAll(GlDropdownItem);

      expect(findPodsDropdown().props('text')).toBe(mockPodName);
      expect(items.length).toBe(mockPods.length);
      mockPods.forEach((pod, i) => {
        const item = items.at(i);
        expect(item.text()).toBe(pod);
      });
    });

    it('populates logs trace', () => {
      const trace = findLogTrace();
      expect(trace.text().split('\n').length).toBe(mockTrace.length);
      expect(trace.text().split('\n')).toEqual(mockTrace);
    });

    it('update control buttons state', () => {
      expect(updateControlBtnsMock).toHaveBeenCalledTimes(1);
    });

    it('scrolls to bottom when loaded', () => {
      expect(scrollDown).toHaveBeenCalledTimes(1);
    });

    describe('when user clicks', () => {
      it('environment name, trace is refreshed', () => {
        const items = findEnvironmentsDropdown().findAll(GlDropdownItem);
        const index = 1; // any env

        expect(actionMocks.showEnvironment).toHaveBeenCalledTimes(0);

        items.at(index).vm.$emit('click');

        expect(actionMocks.showEnvironment).toHaveBeenCalledTimes(1);
        expect(actionMocks.showEnvironment).toHaveBeenLastCalledWith(mockEnvironments[index].name);
      });

      it('pod name, trace is refreshed', () => {
        const items = findPodsDropdown().findAll(GlDropdownItem);
        const index = 2; // any pod

        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(0);

        items.at(index).vm.$emit('click');

        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(1);
        expect(actionMocks.showPodLogs).toHaveBeenLastCalledWith(mockPods[index]);
      });

      it('refresh button, trace is refreshed', () => {
        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(0);

        findLogControlButtons().vm.$emit('refresh');

        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(1);
        expect(actionMocks.showPodLogs).toHaveBeenLastCalledWith(mockPodName);
      });
    });
  });

  describe('when feature flag enable_cluster_application_elastic_stack is enabled', () => {
    let originalGon;

    beforeEach(() => {
      originalGon = window.gon;
      window.gon = { features: { enableClusterApplicationElasticStack: true } };
    });

    afterEach(() => {
      window.gon = originalGon;
    });

    it('displays UI elements', () => {
      initWrapper();

      // elements
      expect(findSearchBar().exists()).toBe(true);
      expect(findSearchBar().is(GlSearchBoxByClick)).toBe(true);
      expect(findTimeWindowDropdown().exists()).toBe(true);
      expect(findTimeWindowDropdown().is(GlDropdown)).toBe(true);

      // layout
      expect(wrapper.find('#environments-dropdown-fg').attributes('class')).toMatch('col-3');
      expect(wrapper.find('#pods-dropdown-fg').attributes('class')).toMatch('col-3');
      expect(wrapper.find('#dates-fg').attributes('class')).toMatch('col-3');
      expect(wrapper.find('#search-fg').attributes('class')).toMatch('col-3');
    });

    describe('loading state', () => {
      beforeEach(() => {
        state.pods.options = [];

        state.logs.lines = [];
        state.logs.isLoading = true;

        state.environments.options = [];
        state.environments.isLoading = true;

        initWrapper();
      });

      it('displays a disabled search bar', () => {
        expect(findSearchBar().exists()).toEqual(true);
        expect(findSearchBar().attributes('disabled')).toEqual('true');
      });

      it('displays a disabled time window dropdown', () => {
        expect(findTimeWindowDropdown().attributes('disabled')).toEqual('true');
      });
    });

    describe('when advanced querying is disabled', () => {
      beforeEach(() => {
        state.pods.options = [];

        state.logs.lines = [];
        state.logs.isLoading = false;

        state.environments.options = [];
        state.environments.isLoading = false;

        state.enableAdvancedQuerying = false;

        initWrapper();
      });

      it('search bar and time window dropdown are disabled', () => {
        expect(findSearchBar().attributes('disabled')).toEqual('true');
        expect(findTimeWindowDropdown().attributes('disabled')).toEqual('true');
      });
    });

    describe('state with data', () => {
      beforeEach(() => {
        actionMocks.setInitData.mockImplementation(mockSetInitData);
        actionMocks.showPodLogs.mockImplementation(mockShowPodLogs);
        actionMocks.fetchEnvironments.mockImplementation(mockFetchEnvs);

        initWrapper();
      });

      it('displays an enabled search bar', () => {
        expect(findSearchBar().attributes('disabled')).toBeFalsy();
      });

      it('displays an enabled time window dropdown', () => {
        expect(findTimeWindowDropdown().attributes('disabled')).toBeFalsy();
      });
    });
  });
});
