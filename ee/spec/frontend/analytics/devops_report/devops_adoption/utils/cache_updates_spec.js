import {
  deleteSegmentsFromCache,
  addSegmentsToCache,
} from 'ee/analytics/devops_report/devops_adoption/utils/cache_updates';
import { devopsAdoptionNamespaceData } from '../mock_data';

describe('addSegmentsToCache', () => {
  const store = {
    readQuery: jest.fn(() => ({ devopsAdoptionEnabledNamespaces: { nodes: [] } })),
    writeQuery: jest.fn(),
  };

  it('calls writeQuery with the correct response', () => {
    addSegmentsToCache(store, devopsAdoptionNamespaceData.nodes);

    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          devopsAdoptionEnabledNamespaces: {
            nodes: devopsAdoptionNamespaceData.nodes,
          },
        },
      }),
    );
  });
});

describe('deleteSegmentsFromCache', () => {
  const store = {
    readQuery: jest.fn(() => ({ devopsAdoptionEnabledNamespaces: devopsAdoptionNamespaceData })),
    writeQuery: jest.fn(),
  };

  it('calls writeQuery with the correct response', () => {
    // Remove the item at the first index
    deleteSegmentsFromCache(store, [devopsAdoptionNamespaceData.nodes[0].id]);

    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.not.objectContaining({
        data: {
          devopsAdoptionEnabledNamespaces: {
            __typename: 'devopsAdoptionEnabledNamespaces',
            nodes: devopsAdoptionNamespaceData.nodes,
          },
        },
      }),
    );
    expect(store.writeQuery).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          devopsAdoptionEnabledNamespaces: {
            __typename: 'devopsAdoptionEnabledNamespaces',
            // Remove the item at the first index
            nodes: devopsAdoptionNamespaceData.nodes.slice(1),
          },
        },
      }),
    );
  });
});
