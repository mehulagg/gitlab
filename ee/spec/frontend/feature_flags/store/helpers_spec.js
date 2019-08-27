import _ from 'lodash-es';
import {
  mapToScopesViewModel,
  mapFromScopesViewModel,
  createNewEnvironmentScope,
} from 'ee/feature_flags/store/modules/helpers';
import {
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  PERCENT_ROLLOUT_GROUP_ID,
  INTERNAL_ID_PREFIX,
  DEFAULT_PERCENT_ROLLOUT,
} from 'ee/feature_flags/constants';

describe('feature flags helpers spec', () => {
  describe('mapToScopesViewModel', () => {
    it('converts the data object from the Rails API into something more usable by Vue', () => {
      const input = [
        {
          id: 3,
          environment_scope: 'environment_scope',
          active: true,
          can_update: true,
          protected: true,
          strategies: [
            {
              name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
              parameters: {
                percentage: '56',
              },
            },
            {
              name: ROLLOUT_STRATEGY_USER_ID,
              parameters: {
                userIds: '123,234',
              },
            },
          ],

          _destroy: true,
        },
      ];

      const expected = [
        {
          id: 3,
          environmentScope: 'environment_scope',
          active: true,
          canUpdate: true,
          protected: true,
          rolloutStrategy: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          rolloutPercentage: '56',
          rolloutUserIds: ['123', '234'],
          shouldBeDestroyed: true,
        },
      ];

      const actual = mapToScopesViewModel(input);

      expect(actual).toEqual(expected);
    });

    it('returns Boolean properties even when their Rails counterparts were not provided (are `undefined`)', () => {
      const input = [
        {
          id: 3,
          environment_scope: 'environment_scope',
        },
      ];

      const [result] = mapToScopesViewModel(input);

      expect(result).toEqual(
        expect.objectContaining({
          active: false,
          canUpdate: false,
          protected: false,
          shouldBeDestroyed: false,
        }),
      );
    });

    it('returns an empty array if null or undefined is provided as a parameter', () => {
      expect(mapToScopesViewModel(null)).toEqual([]);
      expect(mapToScopesViewModel(undefined)).toEqual([]);
    });
  });

  describe('mapFromScopesViewModel', () => {
    it('converts the object emitted from the Vue component into an object than is in the right format to be submitted to the Rails API', () => {
      const input = {
        name: 'name',
        description: 'description',
        scopes: [
          {
            id: 4,
            environmentScope: 'environmentScope',
            active: true,
            canUpdate: true,
            protected: true,
            shouldBeDestroyed: true,
            rolloutStrategy: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
            rolloutPercentage: '48',
            rolloutUserIds: ['123', '234'],
          },
        ],
      };

      const expected = {
        operations_feature_flag: {
          name: 'name',
          description: 'description',
          scopes_attributes: [
            {
              id: 4,
              environment_scope: 'environmentScope',
              active: true,
              can_update: true,
              protected: true,
              _destroy: true,
              strategies: [
                {
                  name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
                  parameters: {
                    groupId: PERCENT_ROLLOUT_GROUP_ID,
                    percentage: '48',
                  },
                },
                {
                  name: ROLLOUT_STRATEGY_USER_ID,
                  parameters: {
                    userIds: '123,234',
                  },
                },
              ],
            },
          ],
        },
      };

      const actual = mapFromScopesViewModel(input);

      expect(actual).toEqual(expected);
    });

    it('should strip out internal IDs', () => {
      const input = {
        scopes: [{ id: 3 }, { id: _.uniqueId(INTERNAL_ID_PREFIX) }],
      };

      const result = mapFromScopesViewModel(input);
      const [realId, internalId] = result.operations_feature_flag.scopes_attributes;

      expect(realId.id).toBe(3);
      expect(internalId.id).toBeUndefined();
    });

    it('returns scopes_attributes as [] if param.scopes is null or undefined', () => {
      let {
        operations_feature_flag: { scopes_attributes: actualScopes },
      } = mapFromScopesViewModel({ scopes: null });

      expect(actualScopes).toEqual([]);

      ({
        operations_feature_flag: { scopes_attributes: actualScopes },
      } = mapFromScopesViewModel({ scopes: undefined }));

      expect(actualScopes).toEqual([]);
    });
  });

  describe('createNewEnvironmentScope', () => {
    it('should return a new environment scope object populated with the default options', () => {
      const expected = {
        environmentScope: '',
        active: false,
        id: expect.stringContaining(INTERNAL_ID_PREFIX),
        rolloutStrategy: ROLLOUT_STRATEGY_ALL_USERS,
        rolloutPercentage: DEFAULT_PERCENT_ROLLOUT,
        rolloutUserIds: [],
      };

      const actual = createNewEnvironmentScope();

      expect(actual).toEqual(expected);
    });

    it('should return a new environment scope object with overrides applied', () => {
      const overrides = {
        environmentScope: 'environmentScope',
        active: true,
      };

      const expected = {
        environmentScope: 'environmentScope',
        active: true,
        id: expect.stringContaining(INTERNAL_ID_PREFIX),
        rolloutStrategy: ROLLOUT_STRATEGY_ALL_USERS,
        rolloutPercentage: DEFAULT_PERCENT_ROLLOUT,
        rolloutUserIds: [],
      };

      const actual = createNewEnvironmentScope(overrides);

      expect(actual).toEqual(expected);
    });
  });
});
