import { DAST_SITE_VALIDATION_STATUS } from 'ee/security_configuration/dast_site_profiles_form/constants';

export const dastSiteProfileCreate = (errors = []) => ({
  data: { dastSiteProfileCreate: { id: '3083', errors } },
});

export const dastSiteProfileUpdate = (errors = []) => ({
  data: { dastSiteProfileUpdate: { id: '3083', errors } },
});

export const dastSiteValidation = (status = DAST_SITE_VALIDATION_STATUS.PENDING) => ({
  data: { project: { dastSiteValidation: { status, id: '1' } } },
});

export const dastSiteValidationCreate = (errors = []) => ({
  data: {
    dastSiteValidationCreate: { status: DAST_SITE_VALIDATION_STATUS.PENDING, id: '1', errors },
  },
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
