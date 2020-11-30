import { isStartEvent, getAllowedEndEvents, eventToOption, eventsByIdentifier } from '../../utils';
import { s__ } from '~/locale';

const I18N = {
  SELECT_START_EVENT: s__('CustomCycleAnalytics|Select start event'),
  SELECT_END_EVENT: s__('CustomCycleAnalytics|Select stop event'),
};

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
