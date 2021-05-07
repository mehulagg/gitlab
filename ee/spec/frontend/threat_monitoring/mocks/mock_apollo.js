import { mockAlerts, mockPageInfo } from './mock_data';

export const defaultQuerySpy = jest.fn().mockResolvedValue({
  data: { project: { alertManagementAlerts: { nodes: mockAlerts, pageInfo: mockPageInfo } } },
});

export const emptyQuerySpy = jest.fn().mockResolvedValue({
  data: {
    project: {
      alertManagementAlerts: {
        nodes: [],
        pageInfo: { endCursor: '', hasNextPage: false, hasPreviousPage: false, startCursor: '' },
      },
    },
  },
});

export const loadingQuerySpy = jest.fn().mockReturnValue(new Promise(() => {}));
