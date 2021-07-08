import axios from '~/lib/utils/axios_utils';

export const fetchIssue = async (issuePath) => {
  return axios.get(issuePath).then(({ data }) => {
    return data;
  });
};

export const fetchIssueStatuses = () => {
  // We are using mock data here which should come from the backend
  return new Promise((resolve) => {
    setTimeout(() => {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      resolve([{ title: 'In Progress' }, { title: 'Done' }]);
    }, 1000);
  });
};

export const updateIssue = (issue, { labels = [], status = undefined }) => {
  // We are using mock call here which should become a backend call
  return new Promise((resolve) => {
    setTimeout(() => {
      const addedLabels = labels.filter((label) => label.set);
      const removedLabelsIds = labels.filter((label) => !label.set).map((label) => label.id);

      const finalLabels = [...issue.labels, ...addedLabels].filter(
        (label) => !removedLabelsIds.includes(label.id),
      );

      resolve({
        ...issue,
        ...(status ? { status } : {}),
        labels: finalLabels,
      });
    }, 1000);
  });
};
