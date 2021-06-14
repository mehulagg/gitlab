import produce from 'immer';
import devopsAdoptionEnabledNamespacesQuery from '../graphql/queries/devops_adoption_enabled_namespaces.query.graphql';

export const addSegmentsToCache = (store, segments, variables) => {
  const sourceData = store.readQuery({
    query: devopsAdoptionEnabledNamespacesQuery,
    variables,
  });

  const data = produce(sourceData, (draftData) => {
    draftData.devopsAdoptionEnabledNamespaces.nodes = [
      ...draftData.devopsAdoptionEnabledNamespaces.nodes,
      ...segments,
    ];
  });

  store.writeQuery({
    query: devopsAdoptionEnabledNamespacesQuery,
    variables,
    data,
  });
};

export const deleteSegmentsFromCache = (store, segmentIds, variables) => {
  const sourceData = store.readQuery({
    query: devopsAdoptionEnabledNamespacesQuery,
    variables,
  });

  const updatedData = produce(sourceData, (draftData) => {
    draftData.devopsAdoptionEnabledNamespaces.nodes = draftData.devopsAdoptionEnabledNamespaces.nodes.filter(
      ({ id }) => !segmentIds.includes(id),
    );
  });

  store.writeQuery({
    query: devopsAdoptionEnabledNamespacesQuery,
    variables,
    data: updatedData,
  });
};
