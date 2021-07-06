<script>
import produce from 'immer';
import createFlash from '~/flash';
import { __, sprintf } from '~/locale';
import { OPENED, REOPENED } from '~/notes/constants';
import { healthStatusQueries } from '../../constants';
import Status from './status.vue';

export default {
  components: {
    Status,
  },
  props: {
    issuableType: {
      type: String,
      required: true,
    },
    iid: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    isOpen() {
      return this.issuableData?.state === OPENED || this.issuableData?.state === REOPENED;
    },
    isLoading() {
      return this.$apollo.queries.issuableData.loading;
    },
    healthStatus() {
      return this.issuableData?.healthStatus;
    },
  },
  apollo: {
    issuableData: {
      query() {
        return healthStatusQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.iid,
        };
      },
      update(data) {
        return {
          healthStatus: data.workspace?.issuable?.healthStatus,
          state: data.workspace?.issuable?.state,
        };
      },
      result({ data }) {
        this.$emit('issuableData', {
          healthStatus: data.workspace?.issuable?.healthStatus,
          state: data.workspace?.issuable?.state,
        });
      },
      error() {
        createFlash({
          message: sprintf(
            __('Something went wrong while setting %{issuableType} health status.'),
            {
              issuableType: this.issuableType,
            },
          ),
        });
      },
    },
  },
  methods: {
    handleDropdownClick(status) {
      return this.$apollo
        .mutate({
          mutation: healthStatusQueries[this.issuableType].mutation,
          variables: {
            projectPath: this.fullPath,
            iid: this.iid,
            healthStatus: status,
          },
          update: (
            _,
            {
              data: {
                updateIssue: {
                  issue: { healthStatus },
                },
              },
            },
          ) => {
            const { defaultClient: client } = this.$apollo.provider.clients;

            const queryVariables = { fullPath: this.fullPath, iid: this.iid };

            const sourceData = client.readQuery({
              query: healthStatusQueries[this.issuableType].query,
              variables: queryVariables,
            });

            const data = produce(sourceData, (draftData) => {
              draftData.workspace.issuable.healthStatus = healthStatus;
            });

            client.writeQuery({
              query: healthStatusQueries[this.issuableType].query,
              variables: queryVariables,
              data,
            });
          },
          optimisticResponse: {
            __typename: 'Mutation', // eslint-disable-line @gitlab/require-i18n-strings
            updateIssue: {
              issue: {
                healthStatus: status,
                __typename: 'Issue', // eslint-disable-line @gitlab/require-i18n-strings
              },
              errors: [],
              __typename: 'UpdateIssuePayload',
            },
          },
        })
        .then(({ data: { updateIssue } = {} } = {}) => {
          const error = updateIssue?.errors[0];
          if (error) {
            createFlash({ message: error });
          }
        })
        .catch(() => {
          createFlash({
            message: sprintf(__('Error occurred while updating the %{issuableType} status'), {
              issuableType: this.issuableType,
            }),
          });
        });
    },
  },
};
</script>

<template>
  <status
    :is-open="isOpen"
    :is-editable="canUpdate"
    :is-fetching="isLoading"
    :status="healthStatus"
    @onDropdownClick="handleDropdownClick"
  />
</template>
