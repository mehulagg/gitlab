export const findName = wrapper => wrapper.find('[data-testid="custom-stage-name"]');
export const findStartEvent = wrapper =>
  wrapper.find('[data-testid="custom-stage-start-event-identifier"]');
export const findEndEvent = wrapper =>
  wrapper.find('[data-testid="custom-stage-end-event-identifier"]');
export const findStartEventLabel = wrapper =>
  wrapper.find('[data-testid="custom-stage-start-event-label-id"]');
export const findEndEventLabel = wrapper =>
  wrapper.find('[data-testid="custom-stage-end-event-label-id"]');

export const formatStartEventOpts = events => [
  { text: 'Select start event', value: null },
  ...events
    .filter(ev => ev.canBeStartEvent)
    .map(({ name: text, identifier: value }) => ({ text, value })),
];

export const formatEndEventOpts = events => [
  { text: 'Select end event', value: null },
  ...events
    .filter(ev => !ev.canBeStartEvent)
    .map(({ name: text, identifier: value }) => ({ text, value })),
];
