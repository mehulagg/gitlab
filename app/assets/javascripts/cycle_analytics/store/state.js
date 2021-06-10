import { DEFAULT_DAYS_TO_DISPLAY } from '../constants';

export default () => ({
  requestPath: '',
  fullPath: '',
  startDate: DEFAULT_DAYS_TO_DISPLAY,
  stages: [],
  summary: [],
  analytics: [],
  stats: [],
  valueStreams: [],
  selectedValueStream: {},
  selectedStage: {},
  selectedStageEvents: [],
  medians: {},
  errorMessage: '',
  hasError: false,
  isLoading: false,
  isLoadingStage: false,
  isEmptyStage: false,
  permissions: {},
});
