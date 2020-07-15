import Vue from 'vue';
import { pick } from 'lodash';
import * as types from './mutation_types';
import { mapToDashboardViewModel, normalizeQueryResponseData } from './utils';
import httpStatusCodes from '~/lib/utils/http_status';
import { BACKOFF_TIMEOUT } from '../../lib/utils/common_utils';
import { dashboardEmptyStates, endpointKeys, initialStateKeys, metricStates } from '../constants';
import { optionsFromSeriesData } from './variable_mapping';

/**
 * Locate and return a metric in the dashboard by its id
 * as generated by `uniqMetricsId()`.
 * @param {String} metricId Unique id in the dashboard
 * @param {Object} dashboard Full dashboard object
 */
const findMetricInDashboard = (metricId, dashboard) => {
  let res = null;
  dashboard.panelGroups.forEach(group => {
    group.panels.forEach(panel => {
      panel.metrics.forEach(metric => {
        if (metric.metricId === metricId) {
          res = metric;
        }
      });
    });
  });
  return res;
};

/**
 * Maps a backened error state to a `metricStates` constant
 * @param {Object} error - Error from backend response
 */
const emptyStateFromError = error => {
  if (!error) {
    return metricStates.UNKNOWN_ERROR;
  }

  // Special error responses
  if (error.message === BACKOFF_TIMEOUT) {
    return metricStates.TIMEOUT;
  }

  // Axios error responses
  const { response } = error;
  if (response && response.status === httpStatusCodes.SERVICE_UNAVAILABLE) {
    return metricStates.CONNECTION_FAILED;
  } else if (response && response.status === httpStatusCodes.BAD_REQUEST) {
    // Note: "error.response.data.error" may contain Prometheus error information
    return metricStates.BAD_QUERY;
  }

  return metricStates.UNKNOWN_ERROR;
};

export default {
  /**
   * Dashboard panels structure and global state
   */
  [types.REQUEST_METRICS_DASHBOARD](state) {
    state.emptyState = dashboardEmptyStates.LOADING;
  },
  [types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, dashboardYML) {
    const { dashboard, panelGroups, variables, links } = mapToDashboardViewModel(dashboardYML);
    state.dashboard = {
      dashboard,
      panelGroups,
    };
    state.variables = variables;
    state.links = links;

    if (!state.dashboard.panelGroups.length) {
      state.emptyState = dashboardEmptyStates.NO_DATA;
    } else {
      state.emptyState = null;
    }
  },
  [types.RECEIVE_METRICS_DASHBOARD_FAILURE](state, error) {
    state.emptyState = error
      ? dashboardEmptyStates.UNABLE_TO_CONNECT
      : dashboardEmptyStates.NO_DATA;
  },

  [types.REQUEST_DASHBOARD_STARRING](state) {
    state.isUpdatingStarredValue = true;
  },
  [types.RECEIVE_DASHBOARD_STARRING_SUCCESS](state, { selectedDashboard, newStarredValue }) {
    const index = state.allDashboards.findIndex(d => d === selectedDashboard);

    state.isUpdatingStarredValue = false;

    // Trigger state updates in the reactivity system for this change
    // https://vuejs.org/v2/guide/reactivity.html#For-Arrays
    Vue.set(state.allDashboards, index, { ...selectedDashboard, starred: newStarredValue });
  },
  [types.RECEIVE_DASHBOARD_STARRING_FAILURE](state) {
    state.isUpdatingStarredValue = false;
  },

  /**
   * Deployments and environments
   */
  [types.RECEIVE_DEPLOYMENTS_DATA_SUCCESS](state, deployments) {
    state.deploymentData = deployments;
  },
  [types.RECEIVE_DEPLOYMENTS_DATA_FAILURE](state) {
    state.deploymentData = [];
  },
  [types.REQUEST_ENVIRONMENTS_DATA](state) {
    state.environmentsLoading = true;
  },
  [types.RECEIVE_ENVIRONMENTS_DATA_SUCCESS](state, environments) {
    state.environmentsLoading = false;
    state.environments = environments;
  },
  [types.RECEIVE_ENVIRONMENTS_DATA_FAILURE](state) {
    state.environmentsLoading = false;
    state.environments = [];
  },

  /**
   * Annotations
   */
  [types.RECEIVE_ANNOTATIONS_SUCCESS](state, annotations) {
    state.annotations = annotations;
  },
  [types.RECEIVE_ANNOTATIONS_FAILURE](state) {
    state.annotations = [];
  },

  /**
   * Dashboard Validation Warnings
   */
  [types.RECEIVE_DASHBOARD_VALIDATION_WARNINGS_SUCCESS](state, hasDashboardValidationWarnings) {
    state.hasDashboardValidationWarnings = hasDashboardValidationWarnings;
  },
  [types.RECEIVE_DASHBOARD_VALIDATION_WARNINGS_FAILURE](state) {
    state.hasDashboardValidationWarnings = false;
  },

  /**
   * Individual panel/metric results
   */
  [types.REQUEST_METRIC_RESULT](state, { metricId }) {
    const metric = findMetricInDashboard(metricId, state.dashboard);
    metric.loading = true;
    if (!metric.result) {
      metric.state = metricStates.LOADING;
    }
  },
  [types.RECEIVE_METRIC_RESULT_SUCCESS](state, { metricId, data }) {
    const metric = findMetricInDashboard(metricId, state.dashboard);
    metric.loading = false;

    if (!data.result || data.result.length === 0) {
      metric.state = metricStates.NO_DATA;
      metric.result = null;
    } else {
      const result = normalizeQueryResponseData(data);

      metric.state = metricStates.OK;
      metric.result = Object.freeze(result);
    }
  },
  [types.RECEIVE_METRIC_RESULT_FAILURE](state, { metricId, error }) {
    const metric = findMetricInDashboard(metricId, state.dashboard);

    metric.state = emptyStateFromError(error);
    metric.loading = false;
    metric.result = null;
  },

  // Parameters and other information
  [types.SET_INITIAL_STATE](state, initialState = {}) {
    Object.assign(state, pick(initialState, initialStateKeys));
  },
  [types.SET_ENDPOINTS](state, endpoints = {}) {
    Object.assign(state, pick(endpoints, endpointKeys));
  },
  [types.SET_TIME_RANGE](state, timeRange) {
    state.timeRange = timeRange;
  },
  [types.SET_GETTING_STARTED_EMPTY_STATE](state) {
    state.emptyState = dashboardEmptyStates.GETTING_STARTED;
  },
  [types.SET_ALL_DASHBOARDS](state, dashboards) {
    state.allDashboards = dashboards || [];
  },
  [types.SET_SHOW_ERROR_BANNER](state, enabled) {
    state.showErrorBanner = enabled;
  },
  [types.SET_PANEL_GROUP_METRICS](state, payload) {
    const panelGroup = state.dashboard.panelGroups.find(pg => payload.key === pg.key);
    panelGroup.panels = payload.panels;
  },
  [types.SET_ENVIRONMENTS_FILTER](state, searchTerm) {
    state.environmentsSearchTerm = searchTerm;
  },
  [types.SET_EXPANDED_PANEL](state, { group, panel }) {
    state.expandedPanel.group = group;
    state.expandedPanel.panel = panel;
  },
  [types.UPDATE_VARIABLE_VALUE](state, { name, value }) {
    const variable = state.variables.find(v => v.name === name);
    if (variable) {
      Object.assign(variable, {
        value,
      });
    }
  },
  [types.UPDATE_VARIABLE_METRIC_LABEL_VALUES](state, { variable, label, data = [] }) {
    const values = optionsFromSeriesData({ label, data });

    // Add new options with assign to ensure Vue reactivity
    Object.assign(variable.options, { values });
  },
};
