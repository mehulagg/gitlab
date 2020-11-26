import { chartKeys } from '../../../constants';
import * as types from './mutation_types';

export default {
  [types.RESET_CHART_DATA](state, chartKey) {
    state.charts[chartKey].data = {};
    state.charts[chartKey].selected = [];
  },
  [types.REQUEST_CHART_DATA](state, chartKey) {
    state.charts[chartKey].isLoading = true;
  },
  [types.RECEIVE_CHART_DATA_SUCCESS](state, { chartKey, data, transformedData }) {
    state.charts[chartKey].isLoading = false;
    state.charts[chartKey].errorCode = null;
    state.charts[chartKey].data = data;

    if (chartKey === chartKeys.scatterplot) {
      state.charts[chartKey].transformedData = transformedData;
    }
  },
  [types.RECEIVE_CHART_DATA_ERROR](state, { chartKey, status }) {
    state.charts[chartKey].isLoading = false;
    state.charts[chartKey].errorCode = status;
    state.charts[chartKey].data = {};

    if (chartKey === chartKeys.scatterplot) {
      state.charts[chartKey].transformedData = [];
    }
  },
  [types.SET_METRIC_TYPE](state, { chartKey, metricType }) {
    state.charts[chartKey].params.metricType = metricType;
  },
  [types.UPDATE_SELECTED_CHART_ITEMS](state, { chartKey, item }) {
    if (!item) {
      state.charts[chartKey].selected = [];
    } else {
      const idx = state.charts[chartKey].selected.indexOf(item);
      if (idx === -1) {
        state.charts[chartKey].selected.push(item);
      } else {
        state.charts[chartKey].selected.splice(idx, 1);
      }
    }
  },
  [types.SET_CHART_ENABLED](state, { chartKey, isEnabled }) {
    state.charts[chartKey].enabled = isEnabled;
  },
};
