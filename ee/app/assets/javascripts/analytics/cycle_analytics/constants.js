import { OVERVIEW_STAGE_ID } from '~/cycle_analytics/constants';
import { __, s__ } from '~/locale';

export const PROJECTS_PER_PAGE = 50;

export const DEFAULT_DAYS_IN_PAST = 30;

export const EVENTS_LIST_ITEM_LIMIT = 50;

export const EMPTY_STAGE_TEXT = {
  issue: __(
    'The issue stage shows the time it takes from creating an issue to assigning the issue to a milestone, or add the issue to a list on your Issue Board. Begin creating issues to see data for this stage.',
  ),
  plan: __(
    'The planning stage shows the time from the previous step to pushing your first commit. This time will be added automatically once you push your first commit.',
  ),
  code: __(
    'The coding stage shows the time from the first commit to creating the merge request. The data will automatically be added here once you create your first merge request.',
  ),
  test: __(
    'The testing stage shows the time GitLab CI takes to run every pipeline for the related merge request. The data will automatically be added after your first pipeline finishes running.',
  ),
  review: __(
    'The review stage shows the time from creating the merge request to merging it. The data will automatically be added after you merge your first merge request.',
  ),
  staging: __(
    'The staging stage shows the time between merging the MR and deploying code to the production environment. The data will be automatically added once you deploy to production for the first time.',
  ),
};

export const DEFAULT_STAGE_NAMES = [...Object.keys(EMPTY_STAGE_TEXT)];

export const TASKS_BY_TYPE_SUBJECT_ISSUE = 'Issue';
export const TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST = 'MergeRequest';
export const TASKS_BY_TYPE_MAX_LABELS = 15;

export const TASKS_BY_TYPE_SUBJECT_FILTER_OPTIONS = {
  [TASKS_BY_TYPE_SUBJECT_ISSUE]: __('Issues'),
  [TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST]: __('Merge Requests'),
};

export const TASKS_BY_TYPE_FILTERS = {
  SUBJECT: 'SUBJECT',
  LABEL: 'LABEL',
};

export const DEFAULT_VALUE_STREAM_ID = 'default';

export const OVERVIEW_METRICS = {
  TIME_SUMMARY: 'TIME_SUMMARY',
  RECENT_ACTIVITY: 'RECENT_ACTIVITY',
};

export const FETCH_VALUE_STREAM_DATA = 'fetchValueStreamData';

export const OVERVIEW_STAGE_CONFIG = {
  id: OVERVIEW_STAGE_ID,
  slug: OVERVIEW_STAGE_ID,
  title: __('Overview'),
  icon: 'home',
};

export const NOT_ENOUGH_DATA_ERROR = s__(
  "ValueStreamAnalyticsStage|We don't have enough data to show this stage.",
);

export const PAGINATION_TYPE = 'keyset';
export const PAGINATION_SORT_FIELD_END_EVENT = 'end_event';
export const PAGINATION_SORT_FIELD_DURATION = 'duration';
export const PAGINATION_SORT_DIRECTION_DESC = 'desc';
export const PAGINATION_SORT_DIRECTION_ASC = 'asc';

export const METRICS_POPOVER_CONTENT = {
  'lead-time': {
    description: s__('ValueStreamAnalytics|Median time from issue created to issue closed.'),
  },
  'cycle-time': {
    description: s__(
      'ValueStreamAnalytics|Median time from issue first merge request created to issue closed.',
    ),
  },
  'new-issues': { description: s__('ValueStreamAnalytics|Number of new issues created.') },
  deploys: { description: s__('ValueStreamAnalytics|Total number of deploys to production.') },
  'deployment-frequency': {
    description: s__('ValueStreamAnalytics|Average number of deployments to production per day.'),
  },
};
