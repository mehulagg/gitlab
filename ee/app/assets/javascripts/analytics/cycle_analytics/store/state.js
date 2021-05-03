import { PAGINATION_SORT_FIELD, PAGINATION_SORT_DIRECTION } from '../constants';

export default () => ({
  featureFlags: {},
  defaultStageConfig: [],

  startDate: null,
  endDate: null,

  isLoading: false,
  isLoadingStage: false,

  isEmptyStage: false,
  errorCode: null,

  isSavingStageOrder: false,
  errorSavingStageOrder: false,

  currentGroup: null,
  selectedProjects: [],
  selectedStage: null,
  selectedValueStream: null,

  currentStageEvents: [],

  isLoadingValueStreams: false,
  isCreatingValueStream: false,
  isEditingValueStream: false,
  isDeletingValueStream: false,

  createValueStreamErrors: {},
  deleteValueStreamError: null,

  stages: [],
  selectedStageError: '',
  summary: [],
  medians: {},
  valueStreams: [],

  pagination: {
    page: null,
    hasNextPage: false,
    // TODO: this should be set in initialization, in case the sort / direction is in the url on load
    sort: PAGINATION_SORT_FIELD,
    direction: PAGINATION_SORT_DIRECTION,
  },
});
