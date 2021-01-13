import { __, s__, sprintf } from '~/locale';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

export const NAME_MAX_LENGTH = 100;

export const I18N = {
  FORM_TITLE: __('Create Value Stream'),
  FORM_CREATED: s__("CreateValueStreamForm|'%{name}' Value Stream created"),
  RECOVER_HIDDEN_STAGE: s__('CreateValueStreamForm|Recover hidden stage'),
  RESTORE_HIDDEN_STAGE: s__('CreateValueStreamForm|Restore stage'),
  RESTORE_STAGES: s__('CreateValueStreamForm|Restore defaults'),
  RECOVER_STAGE_TITLE: s__('CreateValueStreamForm|Default stages'),
  RECOVER_STAGES_VISIBLE: s__('CreateValueStreamForm|All default stages are currently visible'),
  SELECT_START_EVENT: s__('CreateValueStreamForm|Select start event'),
  SELECT_END_EVENT: s__('CreateValueStreamForm|Select end event'),
  FORM_FIELD_NAME_LABEL: s__('CreateValueStreamForm|Name'),
  FORM_FIELD_NAME_PLACEHOLDER: s__('CreateValueStreamForm|Enter a name for the stage'),
  FIELD_STAGE_NAME_PLACEHOLDER: s__('CreateValueStreamForm|Enter stage name'),
  FORM_FIELD_START_EVENT: s__('CreateValueStreamForm|Start event'),
  FORM_FIELD_START_EVENT_LABEL: s__('CreateValueStreamForm|Start event label'),
  FORM_FIELD_END_EVENT: s__('CreateValueStreamForm|End event'),
  FORM_FIELD_END_EVENT_LABEL: s__('CreateValueStreamForm|End event label'),
  DEFAULT_FIELD_START_EVENT_LABEL: s__('CreateValueStreamForm|Start event: '),
  DEFAULT_FIELD_END_EVENT_LABEL: s__('CreateValueStreamForm|End event: '),
  BTN_UPDATE_STAGE: s__('CreateValueStreamForm|Update stage'),
  BTN_ADD_STAGE: s__('CreateValueStreamForm|Add stage'),
  TITLE_EDIT_STAGE: s__('CreateValueStreamForm|Editing stage'),
  TITLE_ADD_STAGE: s__('CreateValueStreamForm|New stage'),
  BTN_CANCEL: __('Cancel'),
  STAGE_INDEX: s__('CreateValueStreamForm|Stage %{index}'),
  HIDDEN_DEFAULT_STAGE: s__('CreateValueStreamForm|%{name} (default)'),
};

export const ERRORS = {
  MIN_LENGTH: s__('CreateValueStreamForm|Name is required'),
  MAX_LENGTH: sprintf(s__('CreateValueStreamForm|Maximum length %{maxLength} characters'), {
    maxLength: NAME_MAX_LENGTH,
  }),
  START_EVENT_REQUIRED: s__('CreateValueStreamForm|Please select a start event first'),
  STAGE_NAME_EXISTS: s__('CreateValueStreamForm|Stage name already exists'),
  INVALID_EVENT_PAIRS: s__(
    'CreateValueStreamForm|Start event changed, please select a valid end event',
  ),
};

export const STAGE_SORT_DIRECTION = {
  UP: 'UP',
  DOWN: 'DOWN',
};

export const defaultErrors = {
  id: [],
  name: [],
  startEventIdentifier: [],
  startEventLabelId: [],
  endEventIdentifier: [],
  endEventLabelId: [],
};

export const defaultFields = {
  id: null,
  name: null,
  startEventIdentifier: null,
  startEventLabelId: null,
  endEventIdentifier: null,
  endEventLabelId: null,
};

const defaultStageCommonFields = { custom: false, hidden: false };

/**
 * These stage configs are copied from the https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/cycle_analytics
 * This is a stopgap solution and we should eventually provide these from an API endpoint
 *
 * More information: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/49094#note_464116439
 */
const BASE_DEFAULT_STAGE_CONFIG = [
  {
    id: 'issue',
    startEventIdentifier: ['issue_created'],
    endEventIdentifier: ['issue_first_associated_with_milestone', 'issue_first_added_to_board'],
  },
  {
    id: 'plan',
    startEventIdentifier: ['issue_first_associated_with_milestone', 'issue_first_added_to_board'],
    endEventIdentifier: ['issue_first_mentioned_in_commit'],
  },
  {
    id: 'code',
    startEventIdentifier: ['issue_first_mentioned_in_commit'],
    endEventIdentifier: ['merge_request_created'],
  },
  {
    id: 'test',
    startEventIdentifier: ['merge_request_last_build_started'],
    endEventIdentifier: ['merge_request_last_build_finished'],
  },
  {
    id: 'review',
    startEventIdentifier: ['merge_request_created'],
    endEventIdentifier: ['merge_request_merged'],
  },
  {
    id: 'staging',
    startEventIdentifier: ['merge_request_merged'],
    endEventIdentifier: ['merge_request_first_deployed_to_production'],
  },
];

export const DEFAULT_STAGE_CONFIG = BASE_DEFAULT_STAGE_CONFIG.map(({ id, ...rest }) => ({
  ...rest,
  ...defaultStageCommonFields,
  name: capitalizeFirstCharacter(id),
}));
