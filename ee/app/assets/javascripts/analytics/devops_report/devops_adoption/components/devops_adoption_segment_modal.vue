<script>
import { GlFormGroup, GlFormInput, GlFormCheckboxTree, GlModal, GlAlert, GlIcon } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import _ from 'lodash';
import { convertToGraphQLId, getIdFromGraphQLId, TYPE_GROUP } from '~/graphql_shared/utils';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  DEVOPS_ADOPTION_GROUP_LEVEL_LABEL,
} from '../constants';
import bulkFindOrCreateDevopsAdoptionSegmentsMutation from '../graphql/mutations/bulk_find_or_create_devops_adoption_segments.mutation.graphql';
import deleteDevopsAdoptionSegmentMutation from '../graphql/mutations/delete_devops_adoption_segment.mutation.graphql';

export default {
  name: 'DevopsAdoptionSegmentModal',
  components: {
    GlModal,
    GlFormGroup,
    GlFormInput,
    GlFormCheckboxTree,
    GlAlert,
    GlIcon,
  },
  inject: {
    isGroup: {
      default: false,
    },
    groupGid: {
      default: null,
    },
  },
  props: {
    groups: {
      type: Array,
      required: true,
    },
    enabledGroups: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  i18n: DEVOPS_ADOPTION_STRINGS.modal,
  data() {
    const checkboxValuesFromEnabledGroups = this.enabledGroups.map((group) =>
      getIdFromGraphQLId(group.namespace.id),
    );

    return {
      checkboxValuesFromEnabledGroups,
      checkboxValues: checkboxValuesFromEnabledGroups,
      filter: '',
      loadingAdd: false,
      loadingDelete: false,
      errors: [],
    };
  },
  computed: {
    loading() {
      return this.loadingAdd || this.loadingDelete;
    },
    checkboxOptions() {
      return this.groups.map(({ id, full_name }) => ({ label: full_name, value: id }));
    },
    cancelOptions() {
      return {
        button: {
          text: this.$options.i18n.cancel,
          attributes: [{ disabled: this.loading }],
        },
      };
    },
    primaryOptions() {
      return {
        button: {
          text: this.$options.i18n.addingButton,
          attributes: [
            {
              variant: 'info',
              loading: this.loading,
              disabled: !this.canSubmit,
            },
          ],
        },
        callback: this.saveChanges,
      };
    },
    canSubmit() {
      return !this.anyChangesMade;
    },
    displayError() {
      return this.errors[0];
    },
    modalTitle() {
      return this.isGroup ? DEVOPS_ADOPTION_GROUP_LEVEL_LABEL : this.$options.i18n.addingTitle;
    },
    filteredOptions() {
      return this.filter
        ? this.checkboxOptions.filter((option) =>
            option.label.toLowerCase().includes(this.filter.toLowerCase()),
          )
        : this.checkboxOptions;
    },
    anyChangesMade() {
      return _.isEqual(
        _.sortBy(this.checkboxValues),
        _.sortBy(this.checkboxValuesFromEnabledGroups),
      );
    },
  },
  methods: {
    async saveChanges() {
      await this.deleteMissingGroups();
      await this.addNewGroups();

      if (!this.errors.length) this.closeModal();
    },
    async addNewGroups() {
      try {
        const originalEnabledIds = this.enabledGroups.map((group) =>
          getIdFromGraphQLId(group.namespace.id),
        );

        const namespaceIds = this.checkboxValues
          .filter((id) => !originalEnabledIds.includes(id))
          .map((id) => convertToGraphQLId(TYPE_GROUP, id));

        if (namespaceIds.length) {
          this.loadingAdd = true;
          const {
            data: {
              bulkFindOrCreateDevopsAdoptionSegments: { errors },
            },
          } = await this.$apollo.mutate({
            mutation: bulkFindOrCreateDevopsAdoptionSegmentsMutation,
            variables: {
              namespaceIds,
            },
            update: (store, { data }) => {
              const {
                bulkFindOrCreateDevopsAdoptionSegments: { segments, errors: requestErrors },
              } = data;

              if (!requestErrors.length) this.$emit('segmentsAdded', segments);
            },
          });

          if (errors.length) {
            this.errors = errors;
          }
        }
      } catch (error) {
        this.errors.push(this.$options.i18n.error);
        Sentry.captureException(error);
      } finally {
        this.loadingAdd = false;
      }
    },
    async deleteMissingGroups() {
      try {
        const removedGroupGids = this.enabledGroups
          .filter(
            (group) =>
              !this.checkboxValues.includes(getIdFromGraphQLId(group.namespace.id)) &&
              group.namespace.id !== this.groupGid,
          )
          .map((group) => group.id);

        if (removedGroupGids.length) {
          this.loadingDelete = true;

          const {
            data: {
              deleteDevopsAdoptionSegment: { errors },
            },
          } = await this.$apollo.mutate({
            mutation: deleteDevopsAdoptionSegmentMutation,
            variables: {
              id: removedGroupGids,
            },
            update: (store, { data }) => {
              const {
                deleteDevopsAdoptionSegment: { errors: requestErrors },
              } = data;

              if (!requestErrors.length) this.$emit('segmentsRemoved', removedGroupGids);
            },
          });

          if (errors.length) {
            this.errors = errors;
          }
        }
      } catch (error) {
        this.errors.push(this.$options.i18n.error);
        Sentry.captureException(error);
      } finally {
        this.loadingDelete = false;
      }
    },
    clearErrors() {
      this.errors = [];
    },
    closeModal() {
      this.$refs.modal.hide();
    },
    resetForm() {
      this.filter = '';
      this.$emit('trackModalOpenState', false);
    },
  },
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
};
</script>
<template>
  <gl-modal
    ref="modal"
    :modal-id="$options.devopsSegmentModalId"
    :title="modalTitle"
    size="sm"
    scrollable
    :action-primary="primaryOptions.button"
    :action-cancel="cancelOptions.button"
    @primary.prevent="primaryOptions.callback"
    @hidden="resetForm"
    @show="$emit('trackModalOpenState', true)"
  >
    <gl-alert v-if="errors.length" variant="danger" class="gl-mb-3" @dismiss="clearErrors">
      {{ displayError }}
    </gl-alert>
    <gl-form-group class="gl-mb-3" data-testid="filter">
      <gl-icon
        name="search"
        :size="18"
        use-deprecated-sizes
        class="gl-text-gray-300 gl-absolute gl-mt-3 gl-ml-3"
      />
      <gl-form-input
        v-model="filter"
        class="gl-pl-7!"
        type="text"
        :placeholder="$options.i18n.filterPlaceholder"
        :disabled="loading"
      />
    </gl-form-group>
    <gl-form-group class="gl-mb-0">
      <gl-form-checkbox-tree
        v-if="filteredOptions.length"
        :key="filteredOptions.length"
        v-model="checkboxValues"
        data-testid="groups"
        :options="filteredOptions"
        :hide-toggle-all="true"
        :disabled="loading"
        class="gl-p-3 gl-pb-0 gl-mb-2 gl-border-1 gl-border-solid gl-border-gray-100 gl-rounded-base"
      />
      <gl-alert v-else variant="info" :dismissible="false" data-testid="filter-warning">
        {{ $options.i18n.noResults }}
      </gl-alert>
    </gl-form-group>
  </gl-modal>
</template>
