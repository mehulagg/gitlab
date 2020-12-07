import produce from 'immer';
import devopsAdoptionSegmentsQuery from '../graphql/queries/devops_adoption_segments.query.graphql';

export const addSegmentToCache = (store, segment) => {
  const sourceData = store.readQuery({
    query: devopsAdoptionSegmentsQuery,
  });

  const data = produce(sourceData, draftData => {
    // eslint-disable-next-line no-param-reassign
    draftData.devopsAdoptionSegments.nodes = [...draftData.devopsAdoptionSegments.nodes, segment];
  });

  store.writeQuery({
    query: devopsAdoptionSegmentsQuery,
    data,
  });
};

export const deleteSegmentFromCache = (store, segmentId) => {
  const sourceData = store.readQuery({
    query: devopsAdoptionSegmentsQuery,
  });

  const updatedData = produce(sourceData, draftData => {
    // eslint-disable-next-line no-param-reassign
    draftData.devopsAdoptionSegments.nodes = draftData.devopsAdoptionSegments.nodes.filter(
      ({ id }) => id !== segmentId,
    );
  });

  store.writeQuery({
    query: devopsAdoptionSegmentsQuery,
    data: updatedData,
  });
};
