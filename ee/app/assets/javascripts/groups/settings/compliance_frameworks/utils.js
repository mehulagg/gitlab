import httpStatus from '~/lib/utils/http_status';
import Api from '~/api';
import { PIPELINE_CONFIGURATION_PATH_FORMAT } from './constants';

export const initialiseFormData = () => ({
  name: null,
  description: null,
  pipelineConfigurationFullPath: null,
  color: null,
});

export const getPipelineConfigurationPathParts = (path) => {
  const [, file, group, project] = path.match(PIPELINE_CONFIGURATION_PATH_FORMAT) || [];

  if (!file || !group || !project) {
    return {};
  }

  return { file, group, project };
};

export const isValidPipelineConfigurationFormat = (path) =>
  PIPELINE_CONFIGURATION_PATH_FORMAT.test(path);

export const checkPipelineConfigurationFileExists = async (file, group, project) => {
  try {
    const { status } = await Api.getRawFile(`${group}/${project}`, file);

    return status === httpStatus.OK;
  } catch (e) {
    return false;
  }
};
