import { isStartEvent, getAllowedEndEvents, eventToOption, eventsByIdentifier } from '../../utils';
import { I18N, ERRORS, defaultErrors, defaultFields, NAME_MAX_LENGTH } from './constants';
import { DEFAULT_STAGE_NAMES } from '../../constants';

/**
 * @typedef {Object} CustomStageEvents
 * @property {String} canBeStartEvent - Title of the metric measured
 * @property {String} name - Friendly name for the event
 * @property {String} identifier - snakeized name for the event
 *
 * @typedef {Object} DropdownData
 * @property {String} text - Friendly name for the event
 * @property {String} value - Value to be submitted for the dropdown
 */

/**
 * Takes an array of custom stage events to return only the
 * events where `canBeStartEvent` is true and converts them
 * to { value, text } pairs for use in dropdowns
 *
 * @param {CustomStageEvents[]} events
 * @returns {DropdownData[]} array of start events formatted for dropdowns
 */
export const startEventOptions = (eventsList) => [
  { value: null, text: I18N.SELECT_START_EVENT },
  ...eventsList.filter(isStartEvent).map(eventToOption),
];

/**
 * Takes an array of custom stage events to return only the
 * events where `canBeStartEvent` is false and converts them
 * to { value, text } pairs for use in dropdowns
 *
 * @param {CustomStageEvents[]} events
 * @returns {DropdownData[]} array end events formatted for dropdowns
 */
export const endEventOptions = (eventsList, startEventIdentifier) => {
  const endEvents = getAllowedEndEvents(eventsList, startEventIdentifier);
  return [
    { value: null, text: I18N.SELECT_END_EVENT },
    ...eventsByIdentifier(eventsList, endEvents).map(eventToOption),
  ];
};

/**
 * @typedef {Object} CustomStageFormData
 * @property {Object.<String, String>} fields - form field values
 * @property {Object.<String, Array>} errors - form field errors
 */

/**
 * Initializes the fields and errors for the custom stages form
 * providing defaults for any missing keys
 *
 * @param {CustomStageFormData} data
 * @returns {CustomStageFormData} the updated initial data with all defaults
 */
export const initializeFormData = ({ fields, errors }) => {
  const initErrors = fields?.endEventIdentifier
    ? defaultErrors
    : {
        ...defaultErrors,
        endEventIdentifier: !fields?.startEventIdentifier ? [ERRORS.START_EVENT_REQUIRED] : [],
      };
  return {
    fields: {
      ...defaultFields,
      ...fields,
    },
    errors: {
      ...initErrors,
      ...errors,
    },
  };
};

/**
 * Validates the form fields for the custom stages form
 * Any errors will be returned in a object where the key is
 * the name of the field.g
 *
 * @param {Object} fields key value pair of form field values
 * @returns {Object} key value pair of form fields with an array of errors
 */
export const validateStage = (fields) => {
  const newErrors = {};

  if (fields?.name) {
    if (fields.name.length > NAME_MAX_LENGTH) {
      newErrors.name = [ERRORS.MAX_LENGTH];
    } else {
      newErrors.name =
        fields?.custom && DEFAULT_STAGE_NAMES.includes(fields.name.toLowerCase())
          ? [ERRORS.STAGE_NAME_EXISTS]
          : [];
    }
  } else {
    newErrors.name = [ERRORS.MIN_LENGTH];
  }

  if (fields?.startEventIdentifier) {
    newErrors.endEventIdentifier = [];
  } else {
    newErrors.endEventIdentifier = [ERRORS.START_EVENT_REQUIRED];
  }

  if (fields?.startEventIdentifier && fields?.endEventIdentifier) {
    newErrors.endEventIdentifier = [];
  }
  return newErrors;
};

/**
 * Validates the name of a value stream Any errors will be
 * returned as an array in a object with key`name`
 *
 * @param {Object} fields key value pair of form field values
 * @returns {Object} key value pair of form fields with an array of errors
 */
export const validateValueStreamName = ({ name = '' }) => {
  const errors = { name: [] };
  if (name.length > NAME_MAX_LENGTH) {
    errors.name.push(ERRORS.MAX_LENGTH);
  }
  if (!name.length) {
    errors.name.push(ERRORS.MIN_LENGTH);
  }
  return errors;
};
