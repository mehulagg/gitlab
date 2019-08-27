import _ from 'lodash-es';
import {
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  INTERNAL_ID_PREFIX,
  DEFAULT_PERCENT_ROLLOUT,
  PERCENT_ROLLOUT_GROUP_ID,
  fetchPercentageParams,
  fetchUserIdParams,
} from '../../constants';

/**
 * Converts raw scope objects fetched from the API into an array of scope
 * objects that is easier/nicer to bind to in Vue.
 * @param {Array} scopesFromRails An array of scope objects fetched from the API
 */
export const mapToScopesViewModel = scopesFromRails =>
  (scopesFromRails || []).map(s => {
    const percentStrategy = (s.strategies || []).find(
      strat => strat.name === ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
    );

    const rolloutStrategy = percentStrategy ? percentStrategy.name : ROLLOUT_STRATEGY_ALL_USERS;

    const rolloutPercentage = fetchPercentageParams(percentStrategy) || DEFAULT_PERCENT_ROLLOUT;

    const userStrategy = (s.strategies || []).find(
      strat => strat.name === ROLLOUT_STRATEGY_USER_ID,
    );

    const rolloutUserIds = (fetchUserIdParams(userStrategy) || '').split(',').filter(id => id);

    return {
      id: s.id,
      environmentScope: s.environment_scope,
      active: Boolean(s.active),
      canUpdate: Boolean(s.can_update),
      protected: Boolean(s.protected),
      rolloutStrategy,
      rolloutPercentage,
      rolloutUserIds,

      // eslint-disable-next-line no-underscore-dangle
      shouldBeDestroyed: Boolean(s._destroy),
    };
  });
/**
 * Converts the parameters emitted by the Vue component into
 * the shape that the Rails API expects.
 * @param {Array} scopesFromVue An array of scope objects from the Vue component
 */
export const mapFromScopesViewModel = params => {
  const scopes = (params.scopes || []).map(s => {
    const percentParameters = {};
    if (s.rolloutStrategy === ROLLOUT_STRATEGY_PERCENT_ROLLOUT) {
      percentParameters.groupId = PERCENT_ROLLOUT_GROUP_ID;
      percentParameters.percentage = s.rolloutPercentage;
    }

    const userIdParameters = {};
    if (Array.isArray(s.rolloutUserIds) && s.rolloutUserIds.length > 0) {
      userIdParameters.userIds = s.rolloutUserIds.join(',');
    }

    // Strip out any internal IDs
    const id = _.isString(s.id) && s.id.startsWith(INTERNAL_ID_PREFIX) ? undefined : s.id;

    const strategies = [
      {
        name: s.rolloutStrategy,
        parameters: percentParameters,
      },
    ];

    if (!_.isEmpty(userIdParameters)) {
      strategies.push({ name: ROLLOUT_STRATEGY_USER_ID, parameters: userIdParameters });
    }

    return {
      id,
      environment_scope: s.environmentScope,
      active: s.active,
      can_update: s.canUpdate,
      protected: s.protected,
      _destroy: s.shouldBeDestroyed,
      strategies,
    };
  });

  return {
    operations_feature_flag: {
      name: params.name,
      description: params.description,
      scopes_attributes: scopes,
    },
  };
};

/**
 * Creates a new feature flag environment scope object for use
 * in a Vue component.  An optional parameter can be passed to
 * override the property values that are created by default.
 *
 * @param {Object} overrides An optional object whose
 * property values will be used to override the default values.
 *
 */
export const createNewEnvironmentScope = (overrides = {}) => {
  const defaultScope = {
    environmentScope: '',
    active: false,
    id: _.uniqueId(INTERNAL_ID_PREFIX),
    rolloutStrategy: ROLLOUT_STRATEGY_ALL_USERS,
    rolloutPercentage: DEFAULT_PERCENT_ROLLOUT,
    rolloutUserIds: [],
  };

  const newScope = {
    ...defaultScope,
    ...overrides,
  };

  if (gon && gon.features && gon.features.featureFlagPermissions) {
    newScope.canUpdate = true;
    newScope.protected = false;
  }

  return newScope;
};
