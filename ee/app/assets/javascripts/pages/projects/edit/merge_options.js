import gql from 'graphql-tag';
import createDefaultClient from '~/lib/graphql';

const containerEl = document.querySelector('#project-merge-options');
const mergePipelinesCheckbox = document.querySelector('.js-merge-options-merge-pipelines');
const mergeTrainsCheckbox = document.querySelector('.js-merge-options-merge-trains');

const getCiCdSettingsQuery = (projectFullPath) =>
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
  `;

const disableMergeTrains = () => {
  mergeTrainsCheckbox.disabled = true;
  mergeTrainsCheckbox.checked = false;
};

export default function () {
  const { projectFullPath } = containerEl.dataset;
  const defaultClient = createDefaultClient();

  defaultClient
    .query({
      query: getCiCdSettingsQuery(projectFullPath),
    })
    .then((result) => {
      const { mergePipelinesEnabled, mergeTrainsEnabled } = result?.data?.project?.ciCdSettings;
      mergePipelinesCheckbox.checked = mergePipelinesEnabled;
      mergeTrainsCheckbox.checked = mergeTrainsEnabled;

      if (!mergePipelinesEnabled) {
        disableMergeTrains();
      }
    })
    .catch(() => {
      if (!mergePipelinesCheckbox.checked) {
        disableMergeTrains();
      }
    });

  mergePipelinesCheckbox.addEventListener('change', () => {
    mergeTrainsCheckbox.disabled = !mergePipelinesCheckbox.checked;

    if (!mergePipelinesCheckbox.checked) {
      mergeTrainsCheckbox.checked = false;
    }
  });
}
