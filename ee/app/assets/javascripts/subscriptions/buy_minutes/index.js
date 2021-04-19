import emptySvg from '@gitlab/svgs/dist/illustrations/security-dashboard-empty-state.svg';
import { GlEmptyState } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import Vue from 'vue';
import { i18n as errorMessages } from '~/ensure_data';
import App from './components/app.vue';
import apolloProvider from './graphql';
import { writeInitialDataToApolloProvider } from './utils';

const { ERROR_FETCHING_DATA_HEADER, ERROR_FETCHING_DATA_DESCRIPTION } = errorMessages;

export default (el) => {
  if (!el) {
    return null;
  }

  try {
    writeInitialDataToApolloProvider(apolloProvider, el.dataset);
  } catch (error) {
    Sentry.captureException(error);
    return new Vue({
      el,
      render(createElement) {
        return createElement(GlEmptyState, {
          props: {
            title: ERROR_FETCHING_DATA_HEADER,
            description: ERROR_FETCHING_DATA_DESCRIPTION,
            svgPath: `data:image/svg+xml;utf8,${encodeURIComponent(emptySvg)}`,
          },
        });
      },
    });
  }

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(App);
    },
  });
};
