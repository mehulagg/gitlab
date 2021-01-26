import listModule from './modules/list';

export const addListType = (store, listType) => {
  const { initialState, namespace } = listType;
  store.registerModule(namespace, listModule());
  store.dispatch('addListType', listType);
  store.dispatch(`${namespace}/setInitialState`, initialState);
};
