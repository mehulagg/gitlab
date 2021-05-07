import axios from '~/lib/utils/axios_utils';
import { getDateInPast } from '~/lib/utils/datetime_utility';
import { chartKeys, scatterPlotAddonQueryDays } from '../../../constants';
import { transformScatterData } from '../../../utils';
import * as types from './mutation_types';

/**
 * Fetches data for all charts except for the main chart
 */
export const fetchSecondaryChartData = ({ state, dispatch }) => {
  Object.keys(state.charts).forEach((chartKey) => {
    if (chartKey !== chartKeys.main) {
      dispatch('fetchChartData', chartKey);
    }
  });
};

export const requestChartData = ({ commit }, chartKey) =>
  commit(types.REQUEST_CHART_DATA, chartKey);

export const fetchChartData = ({ dispatch, getters, state, rootState }, chartKey) => {
  // let's fetch data for enabled charts only
  if (state.charts[chartKey].enabled) {
    dispatch('requestChartData', chartKey);

    const params = getters.getFilterParams(chartKey);

    axios
      .get(rootState.endpoint, { params })
      .then((response) => {
        const { data } = response;

        if (chartKey === chartKeys.scatterplot) {
          const transformedData = transformScatterData(
            data,
            getDateInPast(rootState.filters.startDate, scatterPlotAddonQueryDays),
            new Date(rootState.filters.endDate),
          );

          dispatch('receiveChartDataSuccess', { chartKey, data, transformedData });
        } else {
          dispatch('receiveChartDataSuccess', { chartKey, data });
        }
      })
      .catch((error) => dispatch('receiveChartDataError', { chartKey, error }));
  }
};

export const receiveChartDataSuccess = (
  { commit },
  { chartKey, data = {}, transformedData = null },
) => {
  commit(types.RECEIVE_CHART_DATA_SUCCESS, { chartKey, data, transformedData });
};

export const receiveChartDataError = ({ commit }, { chartKey, error }) => {
  const {
    response: { status },
  } = error;
  commit(types.RECEIVE_CHART_DATA_ERROR, { chartKey, status });
};

export const setMetricType = ({ commit, dispatch }, { chartKey, metricType }) => {
  commit(types.SET_METRIC_TYPE, { chartKey, metricType });

  dispatch('fetchChartData', chartKey);
};

export const updateSelectedItems = ({ commit, dispatch }, { chartKey, item }) => {
  commit(types.UPDATE_SELECTED_CHART_ITEMS, { chartKey, item });

  // update secondary charts
  dispatch('fetchSecondaryChartData');

  // let's reset the page on the MR table and fetch data
  dispatch('table/setPage', 0, { root: true });
};

export const resetMainChartSelection = ({ commit, dispatch }, skipReload = false) => {
  commit(types.UPDATE_SELECTED_CHART_ITEMS, { chartKey: chartKeys.main, item: null });

  if (!skipReload) {
    // update secondary charts
    dispatch('fetchSecondaryChartData');

    // let's reset the page on the MR table and fetch data
    dispatch('table/setPage', 0, { root: true });
  }
};

export const setChartEnabled = ({ commit }, { chartKey, isEnabled }) =>
  commit(types.SET_CHART_ENABLED, { chartKey, isEnabled });
