import subscriptionState from 'ee/billings/stores/modules/subscriptions/state';

export const resetStore = store => {
  const newState = {
    subscription: subscriptionState(),
  };
  store.replaceState(newState);
};
