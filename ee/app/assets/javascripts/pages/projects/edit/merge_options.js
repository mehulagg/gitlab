import gql from 'graphql-tag';
import createDefaultClient from '~/lib/graphql';

const getMergeSettingsStateQuery = (projectFullPath) => (
  gql`
    query {
      project(fullPath:"${projectFullPath}") {
        id,
        ciCdSettings {
          mergePipelinesEnabled,
          mergeTrainsEnabled,
        }
      }
    }
  `
);

export default function () {
  const defaultClient = createDefaultClient();
  const mergePipelinesCheckbox = document.querySelector('.js-merge-options-merge-pipelines');
  const mergeTrainsCheckbox = document.querySelector('.js-merge-options-merge-trains');

  const containerEl = document.querySelector('#project-merge-options');
  const { projectFullPath } = containerEl.dataset;

  defaultClient.query({
    query: getMergeSettingsStateQuery(projectFullPath),
  })
    .then(result => {
      const { mergePipelinesEnabled, mergeTrainsEnabled } = result?.data?.project?.ciCdSettings;
      if (!mergePipelinesEnabled) {
        mergePipelinesCheckbox.disabled = true;
        mergeTrainsCheckbox.disabled = true;
      }

      if (!mergeTrainsEnabled) {
        mergeTrainsCheckbox.disabled = true;
      }
    })
    .catch(() => {
      mergePipelinesCheckbox.disabled = true;
      mergeTrainsCheckbox.disabled = true;
    });
}
