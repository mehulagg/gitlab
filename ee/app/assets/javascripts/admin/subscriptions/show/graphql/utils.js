import produce from 'immer';
import { subscriptionHistoryQueries, subscriptionQueries } from '../constants';

export const getLicenseFromData = ({ data } = {}) => data?.gitlabSubscriptionActivate?.license;
export const getErrorsAsData = ({ data } = {}) => data?.gitlabSubscriptionActivate?.errors || [];

export const updateSubscriptionAppCache = (cache, mutation) => {
  const license = getLicenseFromData(mutation);
  if (!license) {
    return;
  }
  const { query } = subscriptionQueries;
  const { query: historyQuery } = subscriptionHistoryQueries;
  const data = produce({}, (draftData) => {
    draftData.currentLicense = license;
  });
  cache.writeQuery({ query, data });
  const subscriptionsList = cache.readQuery({ query: historyQuery });
  const subscriptionListData = produce(subscriptionsList, (draftData) => {
    draftData.licenseHistoryEntries.nodes = [
      license,
      ...subscriptionsList.licenseHistoryEntries.nodes,
    ];
  });
  cache.writeQuery({ query: historyQuery, data: subscriptionListData });
};
