import { createMockClient } from 'mock-apollo-client';

import getComplianceFrameworkQuery from 'ee/groups/settings/compliance_frameworks/graphql/queries/get_compliance_framework.query.graphql';
import createComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/queries/create_compliance_framework.mutation.graphql';
import updateComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/queries/update_compliance_framework.mutation.graphql';
import ComplianceFrameworksService from 'ee/groups/settings/compliance_frameworks/services/compliance_frameworks_service';

import {
  validFetchOneResponse,
  frameworkFoundResponse,
  emptyFetchResponse,
  validCreateResponse,
  errorCreateResponse,
  validUpdateResponse,
  errorUpdateResponse,
  createData,
  updateData,
} from '../mock_data';

describe('ComplianceFrameworksService', () => {
  let service;
  const groupPath = '/group-1';
  const testId = '1';

  const networkErrorMessage = 'Network error';
  const networkError = new Error(networkErrorMessage);

  const clientNetworkError = jest.fn().mockRejectedValue(networkError);

  const fetch = jest.fn().mockResolvedValue(validFetchOneResponse);
  const fetchEmpty = jest.fn().mockResolvedValue(emptyFetchResponse);

  const create = jest.fn().mockResolvedValue(validCreateResponse);
  const createWithErrors = jest.fn().mockResolvedValue(errorCreateResponse);

  const update = jest.fn().mockResolvedValue(validUpdateResponse);
  const updateWithErrors = jest.fn().mockResolvedValue(errorUpdateResponse);

  const mockClientFactory = (handlers) => {
    const mockClient = createMockClient();

    handlers.forEach(([query, value]) => mockClient.setRequestHandler(query, value));

    return mockClient;
  };

  const serviceFactory = (handlers, id = null) => {
    return new ComplianceFrameworksService(mockClientFactory(handlers), groupPath, id);
  };

  afterEach(() => {
    service = null;
  });

  describe('getComplianceFramework', () => {
    it('returns an empty object when no ID is given', async () => {
      service = serviceFactory([[getComplianceFrameworkQuery, fetch]]);

      expect(await service.getComplianceFramework()).toStrictEqual({});
    });

    it('throws an error if a bad response is returned from the client', async () => {
      service = serviceFactory([[getComplianceFrameworkQuery, clientNetworkError]], testId);

      await expect(service.getComplianceFramework()).rejects.toThrow('Network error');
    });

    it('throws an error if no framework is present in the response', async () => {
      service = serviceFactory([[getComplianceFrameworkQuery, fetchEmpty]], testId);

      await expect(service.getComplianceFramework()).rejects.toThrow(
        'Unknown compliance framework given. Please try a different framework or refresh the page',
      );
    });

    it('returns the correct framework data on success', async () => {
      service = serviceFactory([[getComplianceFrameworkQuery, fetch]], testId);

      expect(await service.getComplianceFramework()).toStrictEqual(frameworkFoundResponse);
    });
  });

  describe('putComplianceFramework', () => {
    it.each`
      hasId
      ${true}
      ${false}
    `('throws an error if a bad response is returned from the client', async ({ hasId }) => {
      const mutation = hasId
        ? updateComplianceFrameworkMutation
        : createComplianceFrameworkMutation;
      const mutationId = hasId ? testId : null;
      const frameworkData = hasId ? updateData : createData;

      service = serviceFactory([[mutation, clientNetworkError]], mutationId);

      await expect(service.putComplianceFramework(frameworkData)).rejects.toThrow(
        'Unable to save this compliance framework. Please try again',
      );
    });

    it.each`
      hasId
      ${true}
      ${false}
    `('throws an error if errors are present in the response', async ({ hasId }) => {
      const mutation = hasId
        ? updateComplianceFrameworkMutation
        : createComplianceFrameworkMutation;
      const mutationId = hasId ? testId : null;
      const frameworkData = hasId ? updateData : createData;
      const response = hasId ? updateWithErrors : createWithErrors;

      service = serviceFactory([[mutation, response]], mutationId);

      await expect(service.putComplianceFramework(frameworkData)).rejects.toThrow(
        'Invalid values given',
      );
    });

    it.each`
      hasId
      ${true}
      ${false}
    `('returns a successful mutation response on success', async ({ hasId }) => {
      const mutation = hasId
        ? updateComplianceFrameworkMutation
        : createComplianceFrameworkMutation;
      const mutationId = hasId ? testId : null;
      const frameworkData = hasId ? updateData : createData;
      const response = hasId ? update : create;
      const expected = hasId
        ? {}
        : {
            ...frameworkFoundResponse,
            __typename: 'ComplianceFramework',
          };

      service = serviceFactory([[mutation, response]], mutationId);

      expect(await service.putComplianceFramework(frameworkData)).toStrictEqual(expected);
    });
  });
});
