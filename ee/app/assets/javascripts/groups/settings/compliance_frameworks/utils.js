import Api from '~/api';
import httpStatus from '~/lib/utils/http_status';
import { isNumeric } from '~/lib/utils/number_utils';
import { EDIT_PATH_ID_FORMAT, PIPELINE_CONFIGURATION_PATH_FORMAT } from './constants';

export const injectIdIntoEditPath = (path, id) => {
  if (!path.match(EDIT_PATH_ID_FORMAT) || !isNumeric(id)) {
    return '';
  }

  return path.replace(EDIT_PATH_ID_FORMAT, `/${id}/`);
};

export const initialiseFormData = () => ({
  name: null,
  description: null,
  pipelineConfigurationFullPath: null,
  color: null,
});

export const getSubmissionParams = (formData, pipelineConfigurationFullPathEnabled) => {
  const params = { ...formData };

  if (!pipelineConfigurationFullPathEnabled) {
    delete params.pipelineConfigurationFullPath;
  }

  return params;
};

export const getPipelineConfigurationPathParts = (path) => {
  const [, file, group, project] = path.match(PIPELINE_CONFIGURATION_PATH_FORMAT) || [];

  return { file, group, project };
};

export const getProjectDefaultBranch = async (group, project) => {
  try {
    const { data } = await Api.project(`${group}/${project}`);

    return { data };
  } catch (e) {
    return false;
  }
}

export const validatePipelineConfirmationFormat = (path) =>
  PIPELINE_CONFIGURATION_PATH_FORMAT.test(path);

export const fetchPipelineConfigurationFileExists = async (path) => {
  const { file, group, project } = getPipelineConfigurationPathParts(path);

  if (!file || !group || !project) {
    return false;
  }

  const { projectData } = await getProjectDefaultBranch(group, project);

  try {
    const { status } = await Api.getRawFile(`${group}/${project}`, file, { ref: `${projectData.default_branch}` });

    return status === httpStatus.OK;
  } catch (e) {
    return false;
  }
};
