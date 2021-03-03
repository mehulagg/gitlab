import Store from 'ee/sidebar/stores/sidebar_store';
import updateStatusMutation from '~/sidebar/queries/updateStatus.mutation.graphql';
import CESidebarMediator from '~/sidebar/sidebar_mediator';

export default class SidebarMediator extends CESidebarMediator {
  initSingleton(options) {
    super.initSingleton(options);
    this.store = new Store(options);
  }

  processFetchedData(restData, graphQlData) {
    super.processFetchedData(restData, graphQlData);
    this.store.setWeightData(restData);
    this.store.setEpicData(restData);
    this.store.setStatusData(graphQlData);
  }

  updateWeight(newWeight) {
    this.store.setLoadingState('weight', true);
    return this.service
      .update('issue', { weight: newWeight })
      .then(({ data }) => {
        this.store.setWeight(data.weight);
        this.store.setLoadingState('weight', false);
      })
      .catch((err) => {
        this.store.setLoadingState('weight', false);
        throw err;
      });
  }

  updateStatus(healthStatus) {
    this.store.setFetchingState('status', true);
    return this.service
      .updateWithGraphQl(updateStatusMutation, { healthStatus })
      .then(({ data }) => {
        if (data?.updateIssue?.errors?.length > 0) {
          throw data.updateIssue.errors[0];
        }
        this.store.setStatus(data?.updateIssue?.issue?.healthStatus);
      })
      .catch((error) => {
        throw error;
      })
      .finally(() => this.store.setFetchingState('status', false));
  }
}
