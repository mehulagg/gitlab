import { groupLabels, labelStartEvent, labelEndEvent } from '../../mock_data';

export const MERGE_REQUEST_CREATED = 'merge_request_created';
export const ISSUE_CREATED = 'issue_created';
export const MERGE_REQUEST_CLOSED = 'merge_request_closed';
export const ISSUE_CLOSED = 'issue_closed';

export const emptyState = {
  id: null,
  name: null,
  startEventIdentifier: null,
  startEventLabelId: null,
  endEventIdentifier: null,
  endEventLabelId: null,
};

export const emptyErrorsState = {
  id: [],
  name: [],
  startEventIdentifier: [],
  startEventLabelId: [],
  endEventIdentifier: ['Please select a start event first'],
  endEventLabelId: [],
};

export const firstLabel = groupLabels[0];

export const formInitialData = {
  id: 74,
  name: 'Cool stage pre',
  startEventIdentifier: labelStartEvent.identifier,
  startEventLabelId: firstLabel.id,
  endEventIdentifier: labelEndEvent.identifier,
  endEventLabelId: firstLabel.id,
};

export const minimumFields = {
  name: 'Cool stage',
  startEventIdentifier: MERGE_REQUEST_CREATED,
  endEventIdentifier: MERGE_REQUEST_CLOSED,
};
