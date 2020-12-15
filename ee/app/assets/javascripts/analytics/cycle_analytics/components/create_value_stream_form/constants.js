import { __, s__ } from '~/locale';

export const I18N = {
  RECOVER_HIDDEN_STAGE: s__('CustomCycleAnalytics|Recover hidden stage'),
  RECOVER_STAGE_TITLE: s__('CustomCycleAnalytics|Default stages'),
  RECOVER_STAGES_VISIBLE: s__('CustomCycleAnalytics|All default stages are currently visible'),
  SELECT_START_EVENT: s__('CustomCycleAnalytics|Select start event'),
  SELECT_END_EVENT: s__('CustomCycleAnalytics|Select end event'),
  FORM_FIELD_NAME: s__('CustomCycleAnalytics|Name'),
  FORM_FIELD_NAME_PLACEHOLDER: s__('CustomCycleAnalytics|Enter a name for the stage'),
  FORM_FIELD_START_EVENT: s__('CustomCycleAnalytics|Start event'),
  FORM_FIELD_START_EVENT_LABEL: s__('CustomCycleAnalytics|Start event label'),
  FORM_FIELD_END_EVENT: s__('CustomCycleAnalytics|End event'),
  FORM_FIELD_END_EVENT_LABEL: s__('CustomCycleAnalytics|End event label'),
  BTN_UPDATE_STAGE: s__('CustomCycleAnalytics|Update stage'),
  BTN_ADD_STAGE: s__('CustomCycleAnalytics|Add stage'),
  TITLE_EDIT_STAGE: s__('CustomCycleAnalytics|Editing stage'),
  TITLE_ADD_STAGE: s__('CustomCycleAnalytics|New stage'),
  BTN_CANCEL: __('Cancel'),
};

export const ERRORS = {
  START_EVENT_REQUIRED: s__('CustomCycleAnalytics|Please select a start event first'),
  STAGE_NAME_EXISTS: s__('CustomCycleAnalytics|Stage name already exists'),
  INVALID_EVENT_PAIRS: s__(
    'CustomCycleAnalytics|Start event changed, please select a valid end event',
  ),
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
