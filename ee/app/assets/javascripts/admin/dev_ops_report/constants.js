import { s__ } from '~/locale';

export const MAX_REQUEST_COUNT = 10;

export const DEVOPS_ADOPTION_SEGMENT_MODAL_ID = 'devopsSegmentModal';

export const DATE_TIME_FORMAT = 'yyyy-mm-dd HH:MM';

export const DEVOPS_ADOPTION_ERROR_KEYS = {
  groups: 'groupsError',
  segments: 'segmentsError',
};

export const DEVOPS_ADOPTION_STRINGS = {
  app: {
    [DEVOPS_ADOPTION_ERROR_KEYS.groups]: s__(
      'DevopsAdoption|There was an error fetching Groups. Please refresh the page to try again.',
    ),
    [DEVOPS_ADOPTION_ERROR_KEYS.segments]: s__(
      'DevopsAdoption|There was an error fetching Segments. Please refresh the page to try again.',
    ),
    tableHeader: {
      text: s__(
        'DevopsAdoption|Feature adoption is based on usage over the last 30 days. Last updated: %{timestamp}.',
      ),
      button: s__('DevopsAdoption|Add new segment'),
    },
  },
  emptyState: {
    title: s__('DevopsAdoption|Add a segment to get started'),
    description: s__(
      'DevopsAdoption|DevOps adoption uses segments to track adoption across key features. Segments are a way to track multiple related projects and groups at once. For example, you could create a segment for the engineering department or a particular product team.',
    ),
    button: s__('DevopsAdoption|Add new segment'),
  },
  modal: {
    title: s__('DevopsAdoption|New segment'),
    button: s__('DevopsAdoption|Create new segment'),
    namePlaceholder: s__('DevopsAdoption|My segment'),
    nameLabel: s__('DevopsAdoption|Name'),
    selectedGroupsTextSingular: s__('DevopsAdoption|%{selectedCount} group selected (20 max)'),
    selectedGroupsTextPlural: s__('DevopsAdoption|%{selectedCount} groups selected (20 max)'),
  },
  table: {
    deleteButton: s__('DevopsAdoption|Delete segment'),
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
};
