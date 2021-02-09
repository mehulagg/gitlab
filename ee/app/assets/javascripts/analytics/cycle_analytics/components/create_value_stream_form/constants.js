import { __, s__, sprintf } from '~/locale';

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
  FORM_FIELD_NAME_LABEL: s__('CreateValueStreamForm|Value Stream name'),
  FORM_FIELD_NAME_PLACEHOLDER: s__('CreateValueStreamForm|Enter value stream name'),
  FORM_FIELD_STAGE_NAME_PLACEHOLDER: s__('CreateValueStreamForm|Enter stage name'),
  FORM_FIELD_START_EVENT: s__('CreateValueStreamForm|Start event'),
  FORM_FIELD_START_EVENT_LABEL: s__('CreateValueStreamForm|Start event label'),
  FORM_FIELD_END_EVENT: s__('CreateValueStreamForm|End event'),
  FORM_FIELD_END_EVENT_LABEL: s__('CreateValueStreamForm|End event label'),
  DEFAULT_FIELD_START_EVENT_LABEL: s__('CreateValueStreamForm|Start event: '),
  DEFAULT_FIELD_END_EVENT_LABEL: s__('CreateValueStreamForm|End event: '),
  BTN_UPDATE_STAGE: s__('CreateValueStreamForm|Update stage'),
  BTN_ADD_STAGE: s__('CreateValueStreamForm|Add stage'),
  BTN_ADD_ANOTHER_STAGE: s__('CreateValueStreamForm|Add another stage'),
  TITLE_EDIT_STAGE: s__('CreateValueStreamForm|Editing stage'),
  TITLE_ADD_STAGE: s__('CreateValueStreamForm|New stage'),
  BTN_CANCEL: __('Cancel'),
  STAGE_INDEX: s__('CreateValueStreamForm|Stage %{index}'),
  HIDDEN_DEFAULT_STAGE: s__('CreateValueStreamForm|%{name} (default)'),
  TEMPLATE_DEFAULT: s__('CreateValueStreamForm|Create from default template'),
  TEMPLATE_BLANK: s__('CreateValueStreamForm|Create from no template'),
  ISSUE_STAGE_END: s__('CreateValueStreamForm|Issue stage end'),
  PLAN_STAGE_START: s__('CreateValueStreamForm|Plan stage start'),
  CODE_STAGE_START: s__('CreateValueStreamForm|Code stage start'),
};

export const ERRORS = {
  VALUE_STREAM_NAME_MIN_LENGTH: s__('CreateValueStreamForm|Name is required'),
  STAGE_NAME_MIN_LENGTH: s__('CreateValueStreamForm|Stage name is required'),
  MAX_LENGTH: sprintf(s__('CreateValueStreamForm|Maximum length %{maxLength} characters'), {
    maxLength: NAME_MAX_LENGTH,
  }),
  START_EVENT_REQUIRED: s__('CreateValueStreamForm|Please select a start event first'),
  END_EVENT_REQUIRED: s__('CreateValueStreamForm|Please select an end event'),
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

export const defaultCustomStageFields = { ...defaultFields, custom: true };

export const PRESET_OPTIONS_DEFAULT = 'default';
export const PRESET_OPTIONS_BLANK = 'blank';
export const PRESET_OPTIONS = [
  {
    text: I18N.TEMPLATE_DEFAULT,
    value: PRESET_OPTIONS_DEFAULT,
  },
  {
    text: I18N.TEMPLATE_BLANK,
    value: PRESET_OPTIONS_BLANK,
  },
];

export const ADDITIONAL_STAGE_EVENTS = [
  {
    identifier: 'issue_stage_end',
    name: I18N.ISSUE_STAGE_END,
  },
  {
    identifier: 'plan_stage_start',
    name: I18N.PLAN_STAGE_START,
  },
  {
    identifier: 'code_stage_start',
    name: I18N.CODE_STAGE_START,
  },
];
