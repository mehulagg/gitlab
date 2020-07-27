export default () => ({
  featureFlags: {},

  startDate: null,
  endDate: null,

  isLoading: false,
  isLoadingStage: false,

  isEmptyStage: false,
  errorCode: null,

  isSavingStageOrder: false,
  errorSavingStageOrder: false,

  selectedGroup: null,
  selectedProjects: [],
  selectedStage: null,
  selectedAuthor: null,
  selectedMilestone: null,
  selectedAssignees: [],
  selectedLabels: [],
  selectedValueStream: null,

  currentStageEvents: [],

  isLoadingValueStreams: false,
  isCreatingValueStream: false,
  createValueStreamErrors: {},

  stages: [],
  summary: [],
  medians: {},
  valueStreams: [],
});
