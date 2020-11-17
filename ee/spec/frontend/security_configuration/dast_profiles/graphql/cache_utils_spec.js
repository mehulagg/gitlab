import {
  appendToPreviousResult,
  removeProfile,
  dastProfilesDeleteResponse,
} from 'ee/security_configuration/dast_profiles/graphql/cache_utils';

describe('EE - DastProfiles GraphQL CacheUtils', () => {
  describe('appendToPreviousResult', () => {
    it.each(['siteProfiles', 'scannerProfiles'])('appends new results to previous', profileType => {
      const previousResult = { project: { [profileType]: { edges: ['foo'] } } };
      const fetchMoreResult = { project: { [profileType]: { edges: ['bar'] } } };

      const expected = { project: { [profileType]: { edges: ['foo', 'bar'] } } };
      const result = appendToPreviousResult(profileType)(previousResult, { fetchMoreResult });

      expect(result).toEqual(expected);
    });
  });

  describe('removeProfile', () => {
    it.each(['foo', 'bar'])('removes the profile with the given id from the cache', profileType => {
      const mockQueryBody = { query: 'foo', variables: { foo: 'bar' } };
      const mockProfiles = [{ id: 0 }, { id: 1 }];
      const mockData = {
        project: {
          [profileType]: {
            edges: [{ node: mockProfiles[0] }, { node: mockProfiles[1] }],
          },
        },
      };
      const mockStore = {
        readQuery: () => mockData,
        writeQuery: jest.fn(),
      };

      removeProfile({
        store: mockStore,
        queryBody: mockQueryBody,
        profileId: mockProfiles[0].id,
        profileType,
      });

      expect(mockStore.writeQuery).toHaveBeenCalledWith({
        ...mockQueryBody,
        data: {
          project: {
            [profileType]: {
              edges: [{ node: mockProfiles[1] }],
            },
          },
        },
      });
    });
  });

  describe('dastProfilesDeleteResponse', () => {
    it('returns a mutation response with the correct shape', () => {
      const mockMutationName = 'mutationName';
      const mockPayloadTypeName = 'payloadTypeName';

      expect(
        dastProfilesDeleteResponse({
          mutationName: mockMutationName,
          payloadTypeName: mockPayloadTypeName,
        }),
      ).toEqual({
        __typename: 'Mutation',
        [mockMutationName]: {
          __typename: mockPayloadTypeName,
          errors: [],
        },
      });
    });
  });
});
