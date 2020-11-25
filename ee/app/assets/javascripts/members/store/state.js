import createState from '~/members/store/state';

export default initialState => {
  const { ldapOverridePath } = initialState;

  return {
    ldapOverridePath,
    memberToOverride: null,
    ldapOverrideConfirmationModalVisible: false,
    ...createState(initialState),
  };
};
