import bulkImportSourceGroupsQuery from '../queries/bulk_import_source_groups.query.graphql';

export class StatusPoller {
  constructor({ client, interval }) {
    this.client = client;
    this.isActive = false;
    this.intervalId = null;
  }

  startPolling() {
    if (this.isActive) {
      return;
    }

    this.isActive = true;
    this.checkImports();
  }

  stopPolling() {
    clearInterval(this.intervalId);
  }

  async checkCurrentImports() {
    const data = await this.client.readQuery({ query: bulkImportSourceGroupsQuery });
    console.log(data);
  }
}
