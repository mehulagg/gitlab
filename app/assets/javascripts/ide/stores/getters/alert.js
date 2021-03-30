import { __ } from '~/locale';

const environmentCallout = 'WEB_IDE_CI_ENVIRONMENTS_GUIDANCE';

const someNodes = (entity, f) => entity?.nodes?.some(f);

const calloutDismissed = (callouts, name) =>
  !someNodes(callouts, ({ featureName, dismissedAt }) => featureName === name && !dismissedAt);

const alerts = [
  {
    show: ({ viewer, gitlabCiStages, callouts }, file) =>
      viewer === 'diff' &&
      file.name === '.gitlab-ci.yml' &&
      calloutDismissed(callouts, environmentCallout) &&
      !someNodes(gitlabCiStages, (stage) =>
        someNodes(stage.groups, (group) => someNodes(group?.jobs, (job) => job?.environment)),
      ),
    props: { variant: 'tip' },
    dismiss: ({ dispatch }) => dispatch('dismissCallout', environmentCallout),
    message: __(
      "No deployments detected. Use environments to control your software's continuous deployment. Learn More.",
    ),
  },
];

export const showAlert = (state) => (file) => alerts.find((a) => a.show(state, file));
