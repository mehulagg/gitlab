import produce from 'immer';
import devopsAdoptionSegmentsQuery from '../graphql/queries/devops_adoption_segments.query.graphql';

export const addSegmentsToCache = (store, segments, variables) => {
  const sourceData = store.readQuery({
    query: devopsAdoptionSegmentsQuery,
    variables,
  });

  const data = produce(sourceData, (draftData) => {
    draftData.devopsAdoptionSegments.nodes = [
      ...draftData.devopsAdoptionSegments.nodes,
      ...segments,
    ];
  });

  store.writeQuery({
    query: devopsAdoptionSegmentsQuery,
    variables,
    data,
  });
};

export const deleteSegmentsFromCache = (store, segmentIds) => {
  const sourceData = store.readQuery({
    query: devopsAdoptionSegmentsQuery,
  });

  const updatedData = produce(sourceData, (draftData) => {
    draftData.devopsAdoptionSegments.nodes = draftData.devopsAdoptionSegments.nodes.filter(
      ({ id }) => !segmentIds.includes(id),
    );
  });

  store.writeQuery({
    query: devopsAdoptionSegmentsQuery,
    data: updatedData,
  });
};
