import { mapState, mapActions } from 'vuex';

const normalizeMap = (map) => {
  return Array.isArray(map)
    ? map.map((key) => ({ key, value: key }))
    : Object.keys(map).map((key) => ({ key, value: map[key] }));
};

const createNamespacedVuexHelper = (baseHelper, mapper) => (namespaceFn, map) => {
  const namespacedMap = normalizeMap(map).reduce(
    (acc, { key, value }) =>
      Object.assign(acc, {
        [key]: function mappedHelper(...args) {
          const namespace = namespaceFn(this);

          return mapper(namespace, value, ...args);
        },
      }),
    {},
  );

  return baseHelper(namespacedMap);
};

export const mapVuexModuleState = createNamespacedVuexHelper(
  mapState,
  (namespace, value, state) => {
    return state[namespace][value];
  },
);

export const mapVuexModuleActions = createNamespacedVuexHelper(
  mapActions,
  (namespace, value, dispatch, ...args) => {
    return dispatch(`${namespace}/${value}`, ...args);
  },
);

export const mapVuexModuleGetters = createNamespacedVuexHelper(
  // mapGetters does not let us use a function as a value.
  // Thankfully mapState passes getters in an arg.
  mapState,
  (namespace, value, state, getters) => {
    return getters[`${namespace}/${value}`];
  },
);
