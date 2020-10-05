import vulnerabilitiesState from 'ee/security_dashboard/store/modules/vulnerabilities/state';
import filterState from 'ee/security_dashboard/store/modules/filters/state';

export const resetStore = store => {
  const newState = {
    vulnerabilities: vulnerabilitiesState(),
    filters: filterState(),
  };
  store.replaceState(newState);
};
