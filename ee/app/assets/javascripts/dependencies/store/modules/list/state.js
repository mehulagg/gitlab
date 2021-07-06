import { FILTER, REPORT_STATUS, SORT_ORDER } from './constants';

export default () => ({
  endpoint: '',
  initialized: false,
  isLoading: false,
  errorLoading: false,
  dependencies: [],
  pageInfo: {
    total: 0,
  },
  reportInfo: {
    status: REPORT_STATUS.ok,
    jobPath: '',
    generatedAt: '',
  },
  filter: FILTER.all,
  sortField: 'severity',
  sortOrder: SORT_ORDER.descending,
});
