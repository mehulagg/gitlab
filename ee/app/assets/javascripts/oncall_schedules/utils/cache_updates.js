import produce from 'immer';
import createFlash from '~/flash';

import { DELETE_SCHEDULE_ERROR } from './error_messages';

const deleteScheduleFromStore = (store, query, { oncallScheduleDestroy }, variables) => {
  const schedule = oncallScheduleDestroy?.schedule;
  if (!schedule) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  const data = produce(sourceData, draftData => {
    // eslint-disable-next-line no-param-reassign
    draftData.project.incidentManagementOncallSchedules.nodes = draftData.project.incidentManagementOncallSchedules.nodes.filter(
      ({ id }) => id !== schedule.id,
    );
  });

  store.writeQuery({
    query,
    variables,
    data,
  });
};

const onError = (data, message) => {
  createFlash({ message });
  throw new Error(data.errors);
};

export const hasErrors = ({ errors = [] }) => errors?.length;

export const updateStoreAfterScheduleDelete = (store, query, data, variables) => {
  if (hasErrors(data)) {
    onError(data, DELETE_SCHEDULE_ERROR);
  } else {
    deleteScheduleFromStore(store, query, data, variables);
  }
};
