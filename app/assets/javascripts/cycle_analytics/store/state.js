import { PAGINATION_SORT_FIELD_END_EVENT, PAGINATION_SORT_DIRECTION_DESC } from '../constants';

export default () => ({
  id: null,
  endpoints: {},
  createdAfter: null,
  createdBefore: null,
  stages: [],
  summary: [],
  analytics: [],
  stats: [],
  valueStreams: [],
  selectedValueStream: {},
  currentGroup: {},
  selectedStage: {},
  selectedStageEvents: [],
  selectedStageError: '',
  medians: {},
  hasError: false,
  isLoading: false,
  isLoadingStage: false,
  isEmptyStage: false,
  permissions: {},
  pagination: {
    page: null,
    hasNextPage: false,
    sort: PAGINATION_SORT_FIELD_END_EVENT,
    direction: PAGINATION_SORT_DIRECTION_DESC,
  },
});
