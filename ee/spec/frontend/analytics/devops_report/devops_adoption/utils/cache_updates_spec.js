import {
  deleteSegmentsFromCache,
  addSegmentsToCache,
} from 'ee/analytics/devops_report/devops_adoption/utils/cache_updates';
import { devopsAdoptionSegmentsData } from '../mock_data';

describe('addSegmentsToCache', () => {
  const store = {
    readQuery: jest.fn(() => ({ devopsAdoptionSegments: { nodes: [] } })),
    writeQuery: jest.fn(),
  };

  it('calls writeQuery with the correct response', () => {
    addSegmentsToCache(store, devopsAdoptionSegmentsData.nodes);

    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          devopsAdoptionSegments: {
            nodes: devopsAdoptionSegmentsData.nodes,
          },
        },
      }),
    );
  });
});

describe('deleteSegmentsFromCache', () => {
  const store = {
    readQuery: jest.fn(() => ({ devopsAdoptionSegments: devopsAdoptionSegmentsData })),
    writeQuery: jest.fn(),
  };

  it('calls writeQuery with the correct response', () => {
    // Remove the item at the first index
    deleteSegmentsFromCache(store, [devopsAdoptionSegmentsData.nodes[0].id]);

    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.not.objectContaining({
        data: {
          devopsAdoptionSegments: {
            __typename: 'devopsAdoptionSegments',
            nodes: devopsAdoptionSegmentsData.nodes,
          },
        },
      }),
    );
    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          devopsAdoptionSegments: {
            __typename: 'devopsAdoptionSegments',
            // Remove the item at the first index
            nodes: devopsAdoptionSegmentsData.nodes.slice(1),
          },
        },
      }),
    );
  });
});
