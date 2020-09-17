export const dastSiteProfileCreate = (errors = []) => ({
  data: { dastSiteProfileCreate: { id: '3083', errors } },
});

export const dastSiteProfileUpdate = (errors = []) => ({
  data: { dastSiteProfileUpdate: { id: '3083', errors } },
});

export const dastSiteValidation = (status = 'FAILED_VALIDATION') => ({
  data: { project: { dastSiteValidation: { status, id: '1' } } },
});

export const dastSiteValidationCreate = (errors = []) => ({
  data: { dastSiteValidationCreate: { status: 'PASSED_VALIDATION', id: '1', errors } },
});

export const dastSiteTokenCreate = ({ id = '1', token = '1', errors = [] }) => ({
  data: {
    dastSiteTokenCreate: {
      id,
      token,
      errors,
    },
  },
});
