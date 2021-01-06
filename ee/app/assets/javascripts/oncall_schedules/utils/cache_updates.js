import produce from 'immer';
import createFlash from '~/flash';

import {
  DELETE_SCHEDULE_ERROR,
  UPDATE_SCHEDULE_ERROR,
  UPDATE_ROTATION_ERROR,
  DELETE_ROTATION_ERROR,
} from './error_messages';

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

const addRotationToStore = (
  store,
  query,
  { oncallRotationCreate: rotation },
  scheduleId,
  variables,
) => {
  if (!rotation) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  // TODO: This needs the rotation backend to be fully integrated to work, for the moment we will place-hold it.
  const data = produce(sourceData, (draftData) => {
    const rotations = [rotation];

    // eslint-disable-next-line no-param-reassign
    draftData.project.incidentManagementOncallSchedules.nodes.find(
      ({ iid }) => iid === scheduleId,
    ).rotations = rotations;
  });

  store.writeQuery({
    query,
    variables,
    data,
  });
};

const updateRotationFromStore = (store, query, { oncallRotationUpdate }, scheduleId, variables) => {
  const rotation = oncallRotationUpdate?.oncallRotation;
  if (!rotation) {
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
      rotation,
    ];
  });

  store.writeQuery({
    query,
    variables,
    data,
  });
};

const deleteRotationFromStore = (store, query, { oncallRotationDestroy }, variables) => {
  const rotation = oncallRotationDestroy?.oncallRotation;
  if (!rotation) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  // TODO: This needs the rotation backend to be fully integrated to work, for the moment we will place-hold it. https://gitlab.com/gitlab-org/gitlab/-/issues/262863
  const data = produce(sourceData, (draftData) => {
    // eslint-disable-next-line no-param-reassign
    draftData.project.incidentManagementOncallSchedules.nodes[0].rotations = [rotation].filter(
      ({ id }) => id !== rotation.id,
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

export const updateStoreAfterRotationAdd = (store, query, data, scheduleId, variables) => {
  if (!hasErrors(data)) {
    addRotationToStore(store, query, data, scheduleId, variables);
  }
};

export const updateStoreAfterRotationEdit = (store, query, data, scheduleId, variables) => {
  if (hasErrors(data)) {
    onError(data, UPDATE_ROTATION_ERROR);
  } else {
    updateRotationFromStore(store, query, data, scheduleId, variables);
  }
};

export const updateStoreAfterRotationDelete = (store, query, data, variables) => {
  if (hasErrors(data)) {
    onError(data, DELETE_ROTATION_ERROR);
  } else {
    deleteRotationFromStore(store, query, data, variables);
  }
};
