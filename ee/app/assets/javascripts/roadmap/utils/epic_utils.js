import createGqClient, { fetchPolicies } from '~/lib/graphql';

export const gqClient = createGqClient(
  {},
  {
    fetchPolicy: fetchPolicies.NO_CACHE,
  },
);

export const addIsChildEpicTrueProperty = (obj) => ({ ...obj, isChildEpic: true });

export const generateKey = (epic) => `${epic.isChildEpic ? 'child-epic-' : 'epic-'}${epic.id}`;
