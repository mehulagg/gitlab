import subscriptionState from 'ee/billings/subscriptions/store/state';

export const resetStore = (store) => {
  const newState = {
    subscription: subscriptionState(),
  };
  store.replaceState(newState);
};
