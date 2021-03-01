import Tracking from '~/tracking';
import { TRACKING_CONTEXT_SCHEMA } from './constants';
import { experimentData } from './utils';

export default class ExperimentTracking {
  constructor(experimentName, { label } = {}) {
    this.label = label;
    this.data = experimentData(experimentName);
  }

  event(action) {
    if (!this.data) {
      return false;
    }

    return Tracking.event(document.body.dataset.page, action, {
      label: this.label,
      context: {
        schema: TRACKING_CONTEXT_SCHEMA,
        data: this.data,
      },
    });
  }
}
