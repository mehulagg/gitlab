import gql from 'graphql-tag';
import bulkImportSourceGroupsQuery from '../queries/bulk_import_source_groups.query.graphql';
import { STATUSES } from '../../../constants';
import { SourceGroupsManager } from './source_groups_manager';

const groupId = i => `group${i}`;

function generateGroupsQuery(groups) {
  return gql`{
    ${groups
      .map(
        (g, idx) =>
          `${groupId(idx)}: group(fullPath: "${g.import_target.target_namespace}/${
            g.import_target.new_name
          }") { id }`,
      )
      .join('\n')}
  }`;
}

export class StatusPoller {
  constructor({ client, interval }) {
    this.client = client;
    this.interval = interval;
    this.timeoutId = null;
  }

  startPolling() {
    if (this.timeoutId) {
      return;
    }

    this.timeoutId = setTimeout(() => this.checkCurrentImports(), this.interval);
  }

  stopPolling() {
    clearTimeout(this.timeoutId);
    this.timeoutId = null;
  }

  async checkCurrentImports() {
    try {
      const { bulkImportSourceGroups } = await this.client.readQuery({
        query: bulkImportSourceGroupsQuery,
      });
      const groupsInProgress = bulkImportSourceGroups.filter(g => g.status === STATUSES.STARTED);
      if (groupsInProgress.length) {
        const { data: results } = await this.client.query({
          query: generateGroupsQuery(groupsInProgress),
          fetchPolicy: 'no-cache',
        });
        const groupManager = new SourceGroupsManager({ cache: this.client.cache });
        const completedGroups = groupsInProgress.filter((_, idx) => Boolean(results[groupId(idx)]));
        completedGroups.forEach(group => {
          groupManager.setImportStatus({ group, status: STATUSES.FINISHED });
        });
      }
    } finally {
      setTimeout(() => this.checkCurrentImports(), this.interval);
    }
  }
}
