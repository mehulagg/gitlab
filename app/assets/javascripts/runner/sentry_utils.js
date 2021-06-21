import * as Sentry from '@sentry/browser';

const COMPONENT_TAG = 'component';

export const reportToSentry = ({ error, component }) => {
  Sentry.withScope((scope) => {
    if (component) {
      scope.setTag(COMPONENT_TAG, component);
    }
    Sentry.captureException(error);
  });
};
