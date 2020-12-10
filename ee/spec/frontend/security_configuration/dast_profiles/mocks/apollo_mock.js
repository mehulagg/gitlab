export const dastSiteValidations = (nodes = []) => ({
  data: {
    project: {
      validations: {
        nodes,
      },
    },
  },
});
