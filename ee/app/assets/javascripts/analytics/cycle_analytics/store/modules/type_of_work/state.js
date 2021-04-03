import { TASKS_BY_TYPE_SUBJECT_ISSUE } from '../../../constants';

export default () => ({
  isLoadingTasksByTypeChart: false,
  isLoadingTasksByTypeChartTopLabels: false,

  subject: TASKS_BY_TYPE_SUBJECT_ISSUE,
  selectedLabelIds: [],
  topRankedLabels: [],
  data: [],

  errorCode: null,
  errorMessage: '',
});
