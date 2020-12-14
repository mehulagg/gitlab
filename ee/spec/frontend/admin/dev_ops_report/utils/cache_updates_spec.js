import {
  deleteSegmentFromCache,
  addSegmentToCache,
} from 'ee/admin/dev_ops_report/utils/cache_updates';
import { devopsAdoptionSegmentsData } from '../mock_data';

describe('addSegmentToCache', () => {
  const store = {
    readQuery: jest.fn(() => ({ devopsAdoptionSegments: { nodes: [] } })),
    writeQuery: jest.fn(),
  };

  it('calls writeQuery with the correct response', () => {
    addSegmentToCache(store, devopsAdoptionSegmentsData.nodes[0]);

    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          devopsAdoptionSegments: {
            nodes: [devopsAdoptionSegmentsData.nodes[0]],
          },
        },
      }),
    );
  });
});

describe('deleteSegmentFromCache', () => {
  const store = {
    readQuery: jest.fn(() => ({ devopsAdoptionSegments: devopsAdoptionSegmentsData })),
    writeQuery: jest.fn(),
  };

  it('calls writeQuery with the correct response', () => {
    // Remove the item at the first index
    deleteSegmentFromCache(store, devopsAdoptionSegmentsData.nodes[0].id);

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
