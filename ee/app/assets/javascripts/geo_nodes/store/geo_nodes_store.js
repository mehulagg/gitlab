import { isNil } from 'lodash';

export default class GeoNodesStore {
  constructor(primaryVersion, primaryRevision, replicableTypes) {
    this.state = {};
    this.state.nodes = [];
    this.state.nodeDetails = {};
    this.state.primaryVersion = primaryVersion;
    this.state.primaryRevision = primaryRevision;
    this.state.replicableTypes = replicableTypes;
  }

  setNodes(nodes) {
    this.state.nodes = nodes.map(node => GeoNodesStore.formatNode(node));
  }

  getNodes() {
    return this.state.nodes;
  }

  setNodeDetails(nodeId, nodeDetails) {
    this.state.nodeDetails[nodeId] = GeoNodesStore.formatNodeDetails(
      nodeDetails,
      this.state.replicableTypes,
    );
  }

  removeNode(node) {
    const indexOfRemovedNode = this.state.nodes.indexOf(node);
    if (indexOfRemovedNode > -1) {
      this.state.nodes.splice(indexOfRemovedNode, 1);
      if (this.state.nodeDetails[node.id]) {
        delete this.state.nodeDetails[node.id];
      }
    }
  }

  getPrimaryNodeVersion() {
    return {
      version: this.state.primaryVersion,
      revision: this.state.primaryRevision,
    };
  }

  getNodeDetails(nodeId) {
    return this.state.nodeDetails[nodeId];
  }

  static formatNode(rawNode) {
    const { id, name, url, primary, current, enabled } = rawNode;
    return {
      id,
      name,
      url,
      primary,
      current,
      enabled,
      internalUrl: rawNode.internal_url || '',
      nodeActionActive: false,
      basePath: rawNode._links.self,
      repairPath: rawNode._links.repair,
      editPath: rawNode.web_edit_url,
      geoProjectsUrl: rawNode.web_geo_projects_url,
      statusPath: rawNode._links.status,
      selectiveSyncShards: rawNode.selective_sync_shards,
    };
  }

  static formatNodeDetails(rawNodeDetails, replicableTypes) {
    const syncStatuses = replicableTypes.map(replicable => {
      return {
        itemEnabled: rawNodeDetails[`${replicable.namePlural}_replication_enabled`],
        itemTitle: replicable.titlePlural,
        itemName: replicable.namePlural,
        itemValue: {
          totalCount: rawNodeDetails[`${replicable.namePlural}_count`],
          successCount: rawNodeDetails[`${replicable.namePlural}_synced_count`],
          failureCount: rawNodeDetails[`${replicable.namePlural}_failed_count`],
          verificationSuccessCount: rawNodeDetails[`${replicable.namePlural}_verified_count`],
          verificationFailureCount:
            rawNodeDetails[`${replicable.namePlural}_verification_failed_count`],
          checksumSuccessCount: rawNodeDetails[`${replicable.namePlural}_checksummed_count`],
          checksumFailureCount: rawNodeDetails[`${replicable.namePlural}_checksum_failed_count`],
        },
        ...replicable,
      };
    });

    // Adds replicable to array as long as value is defined
    const verificationStatuses = syncStatuses.filter(s =>
      Boolean(
        !isNil(s.itemValue.verificationSuccessCount) ||
          !isNil(s.itemValue.verificationFailureCount),
      ),
    );

    // Adds replicable to array as long as value is defined
    const checksumStatuses = syncStatuses.filter(s =>
      Boolean(!isNil(s.itemValue.checksumSuccessCount) || !isNil(s.itemValue.checksumFailureCount)),
    );

    return {
      id: rawNodeDetails.geo_node_id,
      health: rawNodeDetails.health,
      healthy: rawNodeDetails.healthy,
      healthStatus: rawNodeDetails.health_status,
      version: rawNodeDetails.version,
      revision: rawNodeDetails.revision,
      primaryVersion: rawNodeDetails.primaryVersion,
      primaryRevision: rawNodeDetails.primaryRevision,
      statusCheckTimestamp: rawNodeDetails.last_successful_status_check_timestamp * 1000,
      replicationSlotWAL: rawNodeDetails.replication_slots_max_retained_wal_bytes,
      missingOAuthApplication: rawNodeDetails.missing_oauth_application || false,
      syncStatusUnavailable: rawNodeDetails.sync_status_unavailable || false,
      storageShardsMatch: rawNodeDetails.storage_shards_match,
      repositoryVerificationEnabled: rawNodeDetails.repository_verification_enabled,
      replicationSlots: {
        totalCount: rawNodeDetails.replication_slots_count || 0,
        successCount: rawNodeDetails.replication_slots_used_count || 0,
        failureCount: 0,
      },
      syncStatuses,
      verificationStatuses,
      checksumStatuses,
      lastEvent: {
        id: rawNodeDetails.last_event_id || 0,
        timeStamp: rawNodeDetails.last_event_timestamp,
      },
      cursorLastEvent: {
        id: rawNodeDetails.cursor_last_event_id || 0,
        timeStamp: rawNodeDetails.cursor_last_event_timestamp,
      },
      selectiveSyncType: rawNodeDetails.selective_sync_type,
      namespaces: rawNodeDetails.namespaces,
      dbReplicationLag: rawNodeDetails.db_replication_lag_seconds,
    };
  }
}
