import chartState from 'ee/analytics/productivity_analytics/store/modules/charts/state';
import filterState from 'ee/analytics/productivity_analytics/store/modules/filters/state';
import tableState from 'ee/analytics/productivity_analytics/store/modules/table/state';
import state from 'ee/analytics/productivity_analytics/store/state';

const resetStore = (store) => {
  const newState = {
    ...state(),
    filters: filterState(),
    charts: chartState(),
    table: tableState(),
  };

  store.replaceState(newState);
};

export default resetStore;
