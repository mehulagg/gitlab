import createGqClient, { fetchPolicies } from '~/lib/graphql';

export const gqClient = createGqClient(
  {},
  {
    fetchPolicy: fetchPolicies.NO_CACHE,
  },
);

export const flattenGroupProperty = ({ node: epicNode }) => ({
  ...epicNode,
  // We can get rid of below two lines
  // by updating `epic_item_details.vue`
  // once we move to GraphQL permanently.
  groupName: epicNode.group.name,
  groupFullName: epicNode.group.fullName,
});

/**
 * Returns array of epics extracted from GraphQL response
 * discarding the `edges`->`node` nesting
 *
 * @param {Object} edges
 */
export const extractGroupEpics = (edges) => edges.map(flattenGroupProperty);

export const addIsChildEpicTrueProperty = (obj) => ({ ...obj, isChildEpic: true });

export const generateKey = (epic) => `${epic.isChildEpic ? 'child-epic-' : 'epic-'}${epic.id}`;
