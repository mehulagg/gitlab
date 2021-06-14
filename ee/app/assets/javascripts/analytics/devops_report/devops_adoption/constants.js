import { s__, __ } from '~/locale';

export const DEFAULT_POLLING_INTERVAL = 30000;

export const MAX_REQUEST_COUNT = 10;

export const PER_PAGE = 100;

export const DEVOPS_ADOPTION_SEGMENT_MODAL_ID = 'devopsSegmentModal';

export const DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID = 'devopsSegmentDeleteModal';

export const DATE_TIME_FORMAT = 'yyyy-mm-dd HH:MM';

export const DEVOPS_ADOPTION_ERROR_KEYS = {
  groups: 'groupsError',
  segments: 'segmentsError',
  addSegment: 'addSegmentsError',
};

export const TABLE_HEADER_TEXT = s__(
  'DevopsAdoption|Feature adoption is based on usage in the previous calendar month. Last updated: %{timestamp}.',
);

export const DEVOPS_ADOPTION_GROUP_LEVEL_LABEL = s__('DevopsAdoption|Add/remove sub-groups');

export const DEVOPS_ADOPTION_TABLE_REMOVE_BUTTON_DISABLED = s__(
  'DevopsAdoption|You cannot remove the group you are currently in.',
);

export const DEVOPS_ADOPTION_STRINGS = {
  app: {
    [DEVOPS_ADOPTION_ERROR_KEYS.groups]: s__(
      'DevopsAdoption|There was an error fetching Groups. Please refresh the page.',
    ),
    [DEVOPS_ADOPTION_ERROR_KEYS.segments]: s__(
      'DevopsAdoption|There was an error fetching Group adoption data. Please refresh the page.',
    ),
    [DEVOPS_ADOPTION_ERROR_KEYS.addSegment]: s__(
      'DevopsAdoption|There was an error enabling the current group. Please refresh the page.',
    ),
    tableHeader: {
      button: s__('DevopsAdoption|Add/remove groups'),
    },
  },
  emptyState: {
    title: s__('DevopsAdoption|Add a group to get started'),
    description: s__(
      'DevopsAdoption|DevOps adoption tracks the use of key features across your favorite groups. Add a group to the table to begin.',
    ),
    button: s__('DevopsAdoption|Add Group'),
  },
  modal: {
    addingTitle: s__('DevopsAdoption|Add/remove groups'),
    addingButton: s__('DevopsAdoption|Save changes'),
    cancel: __('Cancel'),
    namePlaceholder: s__('DevopsAdoption|My group'),
    filterPlaceholder: s__('DevopsAdoption|Filter by name'),
    error: s__('DevopsAdoption|An error occurred while saving changes. Please try again.'),
    noResults: s__('DevopsAdoption|No filter results.'),
  },
  table: {
    removeButton: s__('DevopsAdoption|Remove Group from the table.'),
  },
  deleteModal: {
    title: s__('DevopsAdoption|Confirm remove Group'),
    confirmationMessage: s__(
      'DevopsAdoption|Are you sure that you would like to remove %{name} from the table?',
    ),
    cancel: __('Cancel'),
    confirm: s__('DevopsAdoption|Remove Group'),
    error: s__('DevopsAdoption|An error occurred while removing the group. Please try again.'),
  },
  tableCell: {
    trueText: s__('DevopsAdoption|Adopted'),
    falseText: s__('DevopsAdoption|Not adopted'),
  },
};

export const DEVOPS_ADOPTION_TABLE_TEST_IDS = {
  TABLE_HEADERS: 'header',
  SEGMENT: 'segmentCol',
  ACTIONS: 'actionsCol',
  LOCAL_STORAGE_SORT_BY: 'localStorageSortBy',
  LOCAL_STORAGE_SORT_DESC: 'localStorageSortDesc',
};

export const DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_BY_STORAGE_KEY =
  'devops_adoption_segments_table_sort_by';

export const DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_DESC_STORAGE_KEY =
  'devops_adoption_segments_table_sort_desc';

export const DEVOPS_ADOPTION_GROUP_COL_LABEL = __('Group');

export const DEVOPS_ADOPTION_TABLE_CONFIGURATION = [
  {
    title: s__('DevopsAdoption|Dev'),
    tab: 'dev',
    cols: [
      {
        key: 'issueOpened',
        label: s__('DevopsAdoption|Issues'),
        tooltip: s__('DevopsAdoption|At least one issue opened'),
        testId: 'issuesCol',
      },
      {
        key: 'mergeRequestOpened',
        label: s__('DevopsAdoption|MRs'),
        tooltip: s__('DevopsAdoption|At least one MR opened'),
        testId: 'mrsCol',
      },
      {
        key: 'mergeRequestApproved',
        label: s__('DevopsAdoption|Approvals'),
        tooltip: s__('DevopsAdoption|At least one approval on an MR'),
        testId: 'approvalsCol',
      },
      {
        key: 'codeOwnersUsedCount',
        label: s__('DevopsAdoption|Code owners'),
        tooltip: s__('DevopsAdoption|Code owners enabled for at least one project'),
        testId: 'codeownersCol',
      },
    ],
  },
  {
    title: s__('DevopsAdoption|Sec'),
    tab: 'sec',
    cols: [
      {
        key: 'securityScanSucceeded',
        label: s__('DevopsAdoption|Scanning'),
        tooltip: s__('DevopsAdoption|At least one security scan of any type run in pipeline'),
        testId: 'scanningCol',
      },
    ],
  },
  {
    title: s__('DevopsAdoption|Ops'),
    tab: 'ops',
    cols: [
      {
        key: 'runnerConfigured',
        label: s__('DevopsAdoption|Runners'),
        tooltip: s__('DevopsAdoption|Runner configured for project/group'),
        testId: 'runnersCol',
      },
      {
        key: 'pipelineSucceeded',
        label: s__('DevopsAdoption|Pipelines'),
        tooltip: s__('DevopsAdoption|At least one pipeline successfully run'),
        testId: 'pipelinesCol',
      },
      {
        key: 'deploySucceeded',
        label: s__('DevopsAdoption|Deploys'),
        tooltip: s__('DevopsAdoption|At least one deploy'),
        testId: 'deploysCol',
      },
    ],
  },
];

export const TRACK_ADOPTION_TAB_CLICK_EVENT = 'i_analytics_dev_ops_adoption';

export const TRACK_DEVOPS_SCORE_TAB_CLICK_EVENT = 'i_analytics_dev_ops_score';
