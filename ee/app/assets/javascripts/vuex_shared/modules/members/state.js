import createState from '~/vuex_shared/modules/members/state';

export default initialState => {
  const { ldapOverridePath } = initialState;

  return {
    ldapOverridePath,
    memberToOverride: null,
    ldapOverrideConfirmationModalVisible: false,
    ...createState(initialState),
  };
};
