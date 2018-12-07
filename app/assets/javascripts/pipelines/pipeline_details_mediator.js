import Visibility from 'visibilityjs';
import Flash from '../flash';
import Poll from '../lib/utils/poll';
import { __ } from '../locale';
import PipelineStore from 'ee/pipelines/stores/pipeline_store'; // eslint-disable-line import/order
import PipelineService from 'ee/pipelines/services/pipeline_service'; // eslint-disable-line import/order

export default class pipelinesMediator {
  constructor(options = {}) {
    this.options = options;
    this.store = new PipelineStore();
    this.service = new PipelineService(options.endpoint);

    this.state = {};
    this.state.isLoading = false;
  }

  fetchPipeline() {
    this.poll = new Poll({
      resource: this.service,
      method: 'getPipeline',
      successCallback: this.successCallback.bind(this),
      errorCallback: this.errorCallback.bind(this),
    });

    if (!Visibility.hidden()) {
      this.state.isLoading = true;
      this.poll.makeRequest();
    } else {
      this.refreshPipeline();
    }

    Visibility.change(() => {
      if (!Visibility.hidden()) {
        this.poll.restart();
      } else {
        this.poll.stop();
      }
    });
  }

  successCallback(response) {
    this.state.isLoading = false;
    this.store.storePipeline(response.data);
  }

  errorCallback() {
    this.state.isLoading = false;
    Flash(__('An error occurred while fetching the pipeline.'));
  }

  refreshPipeline() {
    this.poll.stop();

    return this.service
      .getPipeline()
      .then(response => this.successCallback(response))
      .catch(() => this.errorCallback())
      .finally(() => this.poll.restart());
  }
}
