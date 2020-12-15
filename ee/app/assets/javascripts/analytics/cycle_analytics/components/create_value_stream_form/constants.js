import { s__ } from '~/locale';

export const I18N = {
  SELECT_START_EVENT: s__('CustomCycleAnalytics|Select start event'),
  SELECT_END_EVENT: s__('CustomCycleAnalytics|Select stop event'),
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
