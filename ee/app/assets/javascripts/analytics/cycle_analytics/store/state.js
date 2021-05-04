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
  },
});
