import _ from 'underscore';
import createDiff from './create_diff';
import { joinPaths } from '~/lib/utils/url_utility';
import { __ } from '~/locale';

export const SERVICE_NAME = 'webide-file-sync';

// Before actually connecting to the service, we must delay a bit
// so that the service has sufficiently started.
const SERVICE_DELAY = 8000;
const PROTOCOL = 'webfilesync.gitlab.com';

const cancellableWait = time => {
  let timeoutId = 0;

  const cancel = () => clearTimeout(timeoutId);

  const promise = new Promise(resolve => {
    timeoutId = setTimeout(resolve, time);
  });

  return [promise, cancel];
};

const isErrorResponse = error => error && error.code !== 0;

const isErrorPayload = payload => payload && payload.status_code !== 200;

const getErrorFromResponse = data => {
  if (isErrorResponse(data.error)) {
    return { message: data.error.Message };
  } else if (isErrorPayload(data.payload)) {
    return { message: data.payload.error_message };
  }

  return null;
};

const getFullPath = path => `ws://${joinPaths(window.location.host, path)}?service=${SERVICE_NAME}`;

const createWebSocket = fullPath =>
  new Promise((resolve, reject) => {
    const socket = new WebSocket(fullPath, [PROTOCOL]);
    const resetCallbacks = () => {
      socket.onopen = null;
      socket.onerror = null;
    };

    socket.onopen = () => {
      resetCallbacks();
      resolve(socket);
    };

    socket.onerror = () => {
      resetCallbacks();
      reject(new Error(__('Could not connect to Web IDE file mirror service.')));
    };
  });

export const canConnect = ({ services = [] }) => services.some(name => name === SERVICE_NAME);

export const createMirror = () => {
  let socket = null;
  let cancelHandler = _.noop;
  let nextMessageHandler = _.noop;

  const cancelConnect = () => {
    cancelHandler();
    cancelHandler = _.noop;
  };

  const onCancelConnect = fn => {
    cancelHandler = fn;
  };

  const receiveMessage = ev => {
    const handle = nextMessageHandler;
    nextMessageHandler = _.noop;
    handle(JSON.parse(ev.data));
  };

  const onNextMessage = fn => {
    nextMessageHandler = fn;
  };

  const waitForNextMessage = () =>
    new Promise((resolve, reject) => {
      onNextMessage(data => {
        const err = getErrorFromResponse(data);

        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });

  const uploadDiff = ({ toDelete, patch }) => {
    if (!socket) {
      return Promise.resolve();
    }

    const response = waitForNextMessage();

    const msg = {
      code: 'EVENT',
      namespace: '/files',
      event: 'PATCH',
      payload: { diff: patch, delete_files: toDelete },
    };

    socket.send(JSON.stringify(msg));

    return response;
  };

  return {
    upload(state) {
      return uploadDiff(createDiff(state));
    },
    connect(path) {
      if (socket) {
        this.disconnect();
      }

      const fullPath = getFullPath(path);
      const [wait, cancelWait] = cancellableWait(SERVICE_DELAY);

      onCancelConnect(cancelWait);

      return wait
        .then(() => createWebSocket(fullPath))
        .then(newSocket => {
          socket = newSocket;
          socket.onmessage = receiveMessage;
        });
    },
    disconnect() {
      cancelConnect();

      if (!socket) {
        return;
      }

      socket.close();
      socket = null;
    },
  };
};

export default createMirror();
