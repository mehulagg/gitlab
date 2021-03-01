import Tracking from '~/tracking';
import { TRACKING_CONTEXT_SCHEMA } from './constants';
import { experimentData } from './utils';

export default class ExperimentMixin {
  static event(experimentName, action, options = {}) {
    const standardContext = {
      context: {
        schema: TRACKING_CONTEXT_SCHEMA,
        data: experimentData(experimentName),
      },
    };

    return Tracking.event(document.body.dataset.page, action, {
      ...standardContext,
      ...options,
    });
  }

  static mixin(opts = {}) {
    return {
      computed: {
        trackingOptions() {
          return { ...opts, ...this.tracking };
        },
      },
      methods: {
        track(experimentName, action, data = {}) {
          const options = {
            ...this.trackingOptions,
            ...data,
          };

          ExperimentMixin.event(experimentName, action, options);
        },
      },
    };
  }
}
