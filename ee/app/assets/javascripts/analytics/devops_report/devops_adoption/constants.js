import { s__, __, sprintf } from '~/locale';

export const DEFAULT_POLLING_INTERVAL = 30000;

export const MAX_SEGMENTS = 30;

export const MAX_REQUEST_COUNT = 10;

export const DEVOPS_ADOPTION_SEGMENT_MODAL_ID = 'devopsSegmentModal';

export const DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID = 'devopsSegmentDeleteModal';

export const DATE_TIME_FORMAT = 'yyyy-mm-dd HH:MM';

export const DEVOPS_ADOPTION_ERROR_KEYS = {
  groups: 'groupsError',
  segments: 'segmentsError',
  addSegment: 'addSegmentsError',
};

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
      text: s__(
        'DevopsAdoption|Feature adoption is based on usage in the last calendar month. Last updated: %{timestamp}.',
      ),
      button: s__('DevopsAdoption|Add/remove groups'),
      buttonTooltip: sprintf(s__('DevopsAdoption|Maximum %{maxSegments} groups allowed'), {
        maxSegments: MAX_SEGMENTS,
      }),
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
    headers: {
      name: {
        label: __('Group'),
      },
      issueOpened: {
        label: s__('DevopsAdoption|Issues'),
        tooltip: s__('DevopsAdoption|At least 1 issue opened'),
      },
      mergeRequestOpened: {
        label: s__('DevopsAdoption|MRs'),
        tooltip: s__('DevopsAdoption|At least 1 MR opened'),
      },
      mergeRequestApproved: {
        label: s__('DevopsAdoption|Approvals'),
        tooltip: s__('DevopsAdoption|At least 1 approval on an MR'),
      },
      runnerConfigured: {
        label: s__('DevopsAdoption|Runners'),
        tooltip: s__('DevopsAdoption|Runner configured for project/group'),
      },
      pipelineSucceeded: {
        label: s__('DevopsAdoption|Pipelines'),
        tooltip: s__('DevopsAdoption|At least 1 pipeline successfully run'),
      },
      deploySucceeded: {
        label: s__('DevopsAdoption|Deploys'),
        tooltip: s__('DevopsAdoption|At least 1 deploy'),
      },
      securityScanSucceeded: {
        label: s__('DevopsAdoption|Scanning'),
        tooltip: s__('DevopsAdoption|At least 1 security scan of any type run in pipeline'),
      },
    },
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
  ISSUES: 'issuesCol',
  MRS: 'mrsCol',
  APPROVALS: 'approvalsCol',
  RUNNERS: 'runnersCol',
  PIPELINES: 'pipelinesCol',
  DEPLOYS: 'deploysCol',
  ACTIONS: 'actionsCol',
  SCANNING: 'scanningCol',
  LOCAL_STORAGE_SORT_BY: 'localStorageSortBy',
  LOCAL_STORAGE_SORT_DESC: 'localStorageSortDesc',
};

export const DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_BY_STORAGE_KEY =
  'devops_adoption_segments_table_sort_by';

export const DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_DESC_STORAGE_KEY =
  'devops_adoption_segments_table_sort_desc';
