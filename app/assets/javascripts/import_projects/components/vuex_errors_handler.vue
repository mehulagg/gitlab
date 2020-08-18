<script>
import createFlash from '~/flash';
import { s__, sprintf } from '~/locale';
import { visitUrl } from '~/lib/utils/url_utility';
import WatchStoreMutation from '~/vue_shared/components/watch_store_mutation.vue';
import * as mutationTypes from '../store/mutation_types';

const redirectToUrlInError = e => visitUrl(e.redirectUrl);

export default {
  components: {
    WatchStoreMutation,
  },

  props: {
    providerTitle: {
      type: String,
      required: true,
    },
  },

  mutationTypes,

  methods: {
    handleReceiveReposError({ error }) {
      if (error?.redirectUrl) {
        redirectToUrlInError(error);
      } else {
        createFlash({
          message: sprintf(s__('ImportProjects|Requesting your %{provider} repositories failed'), {
            provider: this.providerTitle,
          }),
        });
      }
    },

    handleReceiveImportError({ error }) {
      const flashMessage = error.reason
        ? sprintf(
            s__('ImportProjects|Importing the project failed: %{reason}'),
            {
              reason: error.reason,
            },
            false,
          )
        : s__('ImportProjects|Importing the project failed');

      createFlash({ message: flashMessage });
    },

    handleReceiveJobsError({ error }) {
      if (error?.redirectUrl) {
        redirectToUrlInError(error);
      } else {
        createFlash({
          message: s__('ImportProjects|Update of imported projects with realtime changes failed'),
        });
      }
    },

    handleReceiveNamespacesError() {
      createFlash({ message: s__('ImportProjects|Requesting namespaces failed') });
    },
  },
};
</script>
<template>
  <div hidden>
    <watch-store-mutation
      :type="$options.mutationTypes.RECEIVE_REPOS_ERROR"
      @mutation="handleReceiveReposError"
    />

    <watch-store-mutation
      :type="$options.mutationTypes.RECEIVE_IMPORT_ERROR"
      @mutation="handleReceiveImportError"
    />

    <watch-store-mutation
      :type="$options.mutationTypes.RECEIVE_JOBS_ERROR"
      @mutation="handleReceiveJobsError"
    />

    <watch-store-mutation
      :type="$options.mutationTypes.RECEIVE_NAMESPACES_ERROR"
      @mutation="handleReceiveNamespacesError"
    />
  </div>
</template>
