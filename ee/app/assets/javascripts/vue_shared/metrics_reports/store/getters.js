import { LOADING, ERROR, SUCCESS } from '../constants';

export const summaryStatus = (state) => {
  if (state.isLoading) {
    return LOADING;
  }

  if (state.hasError || state.numberOfChanges > 0) {
    return ERROR;
  }

  return SUCCESS;
};

export const metrics = (state) => [
  ...state.changedMetrics,
  ...state.newMetrics.map((metric) => ({ ...metric, isNew: true })),
  ...state.removedMetrics.map((metric) => ({ ...metric, wasRemoved: true })),
  ...state.unchangedMetrics,
];
