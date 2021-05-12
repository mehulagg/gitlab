<script>
import { GlButton } from '@gitlab/ui';
import { produce } from 'immer';
import $ from 'jquery';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { __ } from '~/locale';
import mergeRequestQueryVariablesMixin from '../../mixins/merge_request_query_variables';
import getStateQuery from '../../queries/get_state.query.graphql';
import workInProgressQuery from '../../queries/states/work_in_progress.query.graphql';
import removeWipMutation from '../../queries/toggle_wip.mutation.graphql';
import StatusIcon from '../mr_widget_status_icon.vue';

export default {
  name: 'WorkInProgress',
  components: {
    StatusIcon,
    GlButton,
  },
  mixins: [mergeRequestQueryVariablesMixin],
  apollo: {
    userPermissions: {
      query: workInProgressQuery,
      variables() {
        return this.mergeRequestQueryVariables;
      },
      update: (data) => data.project.mergeRequest.userPermissions,
    },
  },
  props: {
    mr: { type: Object, required: true },
    service: { type: Object, required: true },
  },
  data() {
    return {
      userPermissions: {},
      isMakingRequest: false,
    };
  },
  methods: {
    removeWipMutation() {
      const { mergeRequestQueryVariables } = this;

      this.isMakingRequest = true;

      this.$apollo
        .mutate({
          mutation: removeWipMutation,
          variables: {
            ...mergeRequestQueryVariables,
            wip: false,
          },
          update(
            store,
            {
              data: {
                mergeRequestSetWip: {
                  errors,
                  mergeRequest: { mergeableDiscussionsState, workInProgress, title },
                },
              },
            },
          ) {
            if (errors?.length) {
              createFlash(__('Something went wrong. Please try again.'));

              return;
            }

            const sourceData = store.readQuery({
              query: getStateQuery,
              variables: mergeRequestQueryVariables,
            });

            const data = produce(sourceData, (draftState) => {
              draftState.project.mergeRequest.mergeableDiscussionsState = mergeableDiscussionsState;
              draftState.project.mergeRequest.workInProgress = workInProgress;
              draftState.project.mergeRequest.title = title;
            });

            store.writeQuery({
              query: getStateQuery,
              data,
              variables: mergeRequestQueryVariables,
            });
          },
          optimisticResponse: {
            // eslint-disable-next-line @gitlab/require-i18n-strings
            __typename: 'Mutation',
            mergeRequestSetWip: {
              __typename: 'MergeRequestSetWipPayload',
              errors: [],
              mergeRequest: {
                __typename: 'MergeRequest',
                mergeableDiscussionsState: true,
                title: this.mr.title,
                workInProgress: false,
              },
            },
          },
        })
        .then(
          ({
            data: {
              mergeRequestSetWip: {
                mergeRequest: { title },
              },
            },
          }) => {
            createFlash(__('The merge request can now be merged.'), 'notice');
            $('.merge-request .detail-page-description .title').text(title);
          },
        )
        .catch(() => createFlash(__('Something went wrong. Please try again.')))
        .finally(() => {
          this.isMakingRequest = false;
        });
    },
  },
};
</script>

<template>
  <div class="mr-widget-body media">
    <status-icon :show-disabled-button="userPermissions.updateMergeRequest" status="warning" />
    <div class="media-body">
      <div class="gl-ml-3 float-left">
        <span class="gl-font-weight-bold">
          {{ __('This merge request is still a draft.') }}
        </span>
        <span class="gl-display-block text-muted">{{
          __("Draft merge requests can't be merged.")
        }}</span>
      </div>
      <gl-button
        v-if="userPermissions.updateMergeRequest"
        size="small"
        :disabled="isMakingRequest"
        :loading="isMakingRequest"
        class="js-remove-wip gl-ml-3"
        @click="removeWipMutation"
      >
        {{ s__('mrWidget|Mark as ready') }}
      </gl-button>
    </div>
  </div>
</template>
