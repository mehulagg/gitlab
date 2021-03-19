import filterState from 'ee/security_dashboard/store/modules/filters/state';
import vulnerabilitiesState from 'ee/security_dashboard/store/modules/vulnerabilities/state';

export const resetStore = (store) => {
  const newState = {
    vulnerabilities: vulnerabilitiesState(),
    filters: filterState(),
  };
  store.replaceState(newState);
};
