import { uuids } from '../../diffs/utils/uuids';

const requests = {};

export function create() {
  const id = uuids()[0];
  let handlers = [];
  let count = 0;

  const instance = {
    id,
    get count() {
      return count;
    },
    get handlers() {
      return handlers;
    },
    free: () => {
      delete requests[id];
    },
    handle: (onCount, behavior) => {
      handlers[onCount] = behavior;
    },
    eject: (onCount) => {
      handlers[onCount] = null;
    },
    occur: () => {
      count += 1;

      if (handlers[count]) {
        handlers[count](count);
      }
    },
    reset: ({ currentCount = true, handlersList = false } = {}) => {
      if (currentCount) {
        count = 0;
      }

      if (handlersList) {
        handlers = [];
      }
    },
  };

  requests[id] = instance;

  return instance;
}

export function recall(id) {
  return requests[id];
}

export function free(id) {
  recall(id).free();
}
