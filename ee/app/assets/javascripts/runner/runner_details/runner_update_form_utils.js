import {
  modelToUpdateMutationVariables as cemodelToUpdateMutationVariables,
  runnerToModel as ceRunnerToModel,
} from '~/runner/runner_details/runner_update_form_utils';

export const runnerToModel = (runner) => {
  return {
    ...ceRunnerToModel(runner),
    privateProjectsMinutesCostFactor: runner?.privateProjectsMinutesCostFactor,
    publicProjectsMinutesCostFactor: runner?.publicProjectsMinutesCostFactor,
  };
};

export const modelToUpdateMutationVariables = (model) => {
  const { privateProjectsMinutesCostFactor, publicProjectsMinutesCostFactor } = model;

  return {
    input: {
      ...cemodelToUpdateMutationVariables(model).input,
      privateProjectsMinutesCostFactor:
        privateProjectsMinutesCostFactor !== '' ? privateProjectsMinutesCostFactor : null,
      publicProjectsMinutesCostFactor:
        publicProjectsMinutesCostFactor !== '' ? publicProjectsMinutesCostFactor : null,
    },
  };
};
