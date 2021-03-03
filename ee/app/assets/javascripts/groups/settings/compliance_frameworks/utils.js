import Api from '~/api';
import httpStatus from '~/lib/utils/http_status';
import { PIPELINE_CONFIGURATION_PATH_FORMAT } from './constants';

export const initialiseFormData = () => ({
  name: null,
  description: null,
  pipelineConfigurationFullPath: null,
  color: null,
});

export const getPipelineConfigurationPathParts = (path) => {
  const [, file, group, project] = path.match(PIPELINE_CONFIGURATION_PATH_FORMAT) || [];

  return { file, group, project };
};

export const validatePipelineConfirmationFormat = (path) =>
  PIPELINE_CONFIGURATION_PATH_FORMAT.test(path);

export const fetchPipelineConfigurationFileExists = async (path) => {
  const { file, group, project } = getPipelineConfigurationPathParts(path);

  if (!file || !group || !project) {
    return false;
  }

  try {
    const { status } = await Api.getRawFile(`${group}/${project}`, file);

    return status === httpStatus.OK;
  } catch (e) {
    return false;
  }
};
