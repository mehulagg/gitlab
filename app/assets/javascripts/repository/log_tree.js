import axios from '~/lib/utils/axios_utils';
import getCommits from './queries/getCommits.query.graphql';
import getProjectPath from './queries/getProjectPath.query.graphql';
import getRef from './queries/getRef.query.graphql';
import { truncate } from '../lib/utils/text_utility';
import { getTimeago } from '../lib/utils/datetime_utility';

let fetchpromise;
let resolvers = [];

export function normalizeData(data) {
  const timeago = getTimeago();

  return data.map(d => ({
    sha: d.commit.id,
    message: d.commit.message.substr(0, 150),
    committedDate: d.commit.committed_date,
    committedTimeago: timeago.format(d.commit.committed_date),
    commitPath: d.commit_path,
    fileName: d.file_name,
    type: d.type,
    __typename: 'LogTreeCommit',
  }));
}

export function resolveCommit(commits, { resolve, entry }) {
  const commit = commits.find(c => c.fileName === entry.name && c.type === entry.type);

  if (commit) {
    resolve(commit);
  }
}

export function fetchLogsTree(client, path, offset, resolver = null) {
  if (resolver) {
    resolvers.push(resolver);
  }

  if (fetchpromise) return fetchpromise;

  const { projectPath } = client.readQuery({ query: getProjectPath });
  const { ref } = client.readQuery({ query: getRef });

  fetchpromise = axios
    .get(`${gon.gitlab_url}/${projectPath}/refs/${ref}/logs_tree${path ? `/${path}` : ''}`, {
      params: { format: 'json', offset },
    })
    .then(({ data, headers }) => {
      const headerLogsOffset = headers['more-logs-offset'];
      const { commits } = client.readQuery({ query: getCommits });
      const newCommitData = [...commits, ...normalizeData(data)];
      client.writeQuery({
        query: getCommits,
        data: { commits: newCommitData },
      });

      resolvers.forEach(r => resolveCommit(newCommitData, r));

      fetchpromise = null;

      if (headerLogsOffset) {
        fetchLogsTree(client, path, headerLogsOffset);
      } else {
        resolvers = [];
      }
    });

  return fetchpromise;
}
