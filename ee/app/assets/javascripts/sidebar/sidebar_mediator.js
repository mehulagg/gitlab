import Store from 'ee/sidebar/stores/sidebar_store';
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
}
