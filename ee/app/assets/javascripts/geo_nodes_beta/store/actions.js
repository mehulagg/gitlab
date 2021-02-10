import Api from 'ee/api';
import createFlash from '~/flash';
import { __ } from '~/locale';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import * as types from './mutation_types';

export const fetchNodes = ({ commit }) => {
  commit(types.REQUEST_NODES);

  const promises = [Api.getGeoNodes(), Api.getGeoNodesStatus()];

  Promise.all(promises)
    .then(([{ data: nodes }, { data: statuses }]) => {
      const inflatedNodes = nodes.map((node) => {
        return convertObjectPropsToCamelCase({
          ...node,
          ...statuses.find((status) => status.geo_node_id === node.id),
        });
      });

      commit(types.RECEIVE_NODES_SUCCESS, inflatedNodes);
    })
    .catch(() => {
      createFlash({ message: __('There was an error fetching the Geo Nodes') });
      commit(types.RECEIVE_NODES_ERROR);
    });
};
