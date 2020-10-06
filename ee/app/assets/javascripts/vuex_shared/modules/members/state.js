import createState from '~/vuex_shared/modules/members/state';

export default initialState => {
  const { ldapOverridePath } = initialState;

  return {
    ldapOverridePath,
    ...createState(initialState),
  };
};
