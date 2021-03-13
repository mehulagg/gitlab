import axios from '~/lib/utils/axios_utils';
import NotesHub from '~/notes/event_hub';
import { MR_METADATA_NETWORK_ERROR_FAILED } from '~/notes/events';

import { MR_METADATA_NETWORK_FAILURE } from '../../i18n';

// Actions that connect to the network in some way (probably an API call)

export function fetchMrMetadata({ dispatch, state }) {
  if (state.endpoints?.metadata) {
    axios
      .get(state.endpoints.metadata)
      .then((response) => {
        dispatch('setMrMetadata', response.data);
      })
      .catch(() => {
        NotesHub.$emit(MR_METADATA_NETWORK_ERROR_FAILED, {
          errors: [
            {
              type: 'warning',
              message: MR_METADATA_NETWORK_FAILURE,
            },
          ],
        });
      });
  }
}
