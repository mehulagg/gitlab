import createGqClient, { fetchPolicies } from '~/lib/graphql';

/*
  This file uses a NO_CACHE policy due to the need for Geo data to always be fresh.
  The UI this serves is used to watch the "syncing" process of items and their statuses
  will need to be constantly re-queried as the user navigates around to not mistakenly
  think the sync process is broken.
*/

export const gqClient = createGqClient(
  {},
  {
    fetchPolicy: fetchPolicies.NO_CACHE,
  },
);
