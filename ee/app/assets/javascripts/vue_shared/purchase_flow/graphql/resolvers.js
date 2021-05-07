import produce from 'immer';
import activeStepQuery from './queries/active_step.query.graphql';
import stepListQuery from './queries/step_list.query.graphql';

function updateActiveStep(_, { id }, { cache }) {
  const sourceData = cache.readQuery({ query: activeStepQuery });
  const { stepList } = cache.readQuery({ query: stepListQuery });
  const activeStep = stepList.find((step) => step.id === id);

  const data = produce(sourceData, (draftData) => {
    draftData.activeStep = {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      __typename: 'Step',
      id: activeStep.id,
    };
  });

  return cache.writeQuery({ query: activeStepQuery, data });
}

function activateNextStep(parent, _, { cache }) {
  const sourceData = cache.readQuery({ query: activeStepQuery });
  const { stepList } = cache.readQuery({ query: stepListQuery });
  const index = stepList.findIndex((step) => step.id === sourceData.activeStep.id);
  const activeStep = stepList[index + 1];

  const data = produce(sourceData, (draftData) => {
    draftData.activeStep = {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      __typename: 'Step',
      id: activeStep.id,
    };
  });

  return cache.writeQuery({ query: activeStepQuery, data });
}

export default {
  Mutation: {
    updateActiveStep,
    activateNextStep,
  },
};
