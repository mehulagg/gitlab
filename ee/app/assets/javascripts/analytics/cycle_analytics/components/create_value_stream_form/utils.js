import { isStartEvent, getAllowedEndEvents, eventToOption, eventsByIdentifier } from '../../utils';
import { I18N, ERRORS, defaultErrors, defaultFields } from './constants';
import { DEFAULT_STAGE_NAMES } from '../../constants';

export const startEventOptions = eventsList => [
  { value: null, text: I18N.SELECT_START_EVENT },
  ...eventsList.filter(isStartEvent).map(eventToOption),
];

export const endEventOptions = (eventsList, startEventIdentifier) => {
  const endEvents = getAllowedEndEvents(eventsList, startEventIdentifier);
  return [
    { value: null, text: I18N.SELECT_END_EVENT },
    ...eventsByIdentifier(eventsList, endEvents).map(eventToOption),
  ];
};

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

export const validateFields = fields => {
  const newErrors = {};

  if (fields?.name) {
    newErrors.name = DEFAULT_STAGE_NAMES.includes(fields?.name.toLowerCase())
      ? [ERRORS.STAGE_NAME_EXISTS]
      : [];
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
