import produce from 'immer';
import createFlash from '~/flash';

import { DELETE_SCHEDULE_ERROR, UPDATE_SCHEDULE_ERROR } from './error_messages';

const addScheduleToStore = (store, query, { oncallSchedule: schedule }, variables) => {
  if (!schedule) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  const data = produce(sourceData, (draftData) => {
    draftData.project.incidentManagementOncallSchedules.nodes.push(schedule);
  });

  store.writeQuery({
    query,
    variables,
    data,
  });
};

const deleteScheduleFromStore = (store, query, { oncallScheduleDestroy }, variables) => {
  const schedule = oncallScheduleDestroy?.oncallSchedule;
  if (!schedule) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  const data = produce(sourceData, (draftData) => {
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

const updateScheduleFromStore = (store, query, { oncallScheduleUpdate }, variables) => {
  const schedule = oncallScheduleUpdate?.oncallSchedule;
  if (!schedule) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  const data = produce(sourceData, (draftData) => {
    // eslint-disable-next-line no-param-reassign
    draftData.project.incidentManagementOncallSchedules.nodes = [
      ...draftData.project.incidentManagementOncallSchedules.nodes,
      schedule,
    ];
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

export const updateStoreOnScheduleCreate = (store, query, data, variables) => {
  if (!hasErrors(data)) {
    addScheduleToStore(store, query, data, variables);
  }
};

export const updateStoreAfterScheduleDelete = (store, query, data, variables) => {
  if (hasErrors(data)) {
    onError(data, DELETE_SCHEDULE_ERROR);
  } else {
    deleteScheduleFromStore(store, query, data, variables);
  }
};

export const updateStoreAfterScheduleEdit = (store, query, data, variables) => {
  if (hasErrors(data)) {
    onError(data, UPDATE_SCHEDULE_ERROR);
  } else {
    updateScheduleFromStore(store, query, data, variables);
  }
};
