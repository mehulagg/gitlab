<script>
import { GlFormGroup, GlFormInput, GlFormRadioGroup, GlModal, GlAlert, GlIcon } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { convertToGraphQLId, TYPE_GROUP } from '~/graphql_shared/utils';
import { DEVOPS_ADOPTION_STRINGS, DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from '../constants';
import createDevopsAdoptionSegmentMutation from '../graphql/mutations/create_devops_adoption_segment.mutation.graphql';
import { addSegmentToCache } from '../utils/cache_updates';

export default {
  name: 'DevopsAdoptionSegmentModal',
  components: {
    GlModal,
    GlFormGroup,
    GlFormInput,
    GlFormRadioGroup,
    GlAlert,
    GlIcon,
  },
  props: {
    groups: {
      type: Array,
      required: true,
    },
  },
  i18n: DEVOPS_ADOPTION_STRINGS.modal,
  data() {
    return {
      selectedGroupId: null,
      filter: '',
      loading: false,
      errors: [],
    };
  },
  computed: {
    checkboxOptions() {
      return this.groups.map(({ id, full_name }) => ({ text: full_name, value: id }));
    },
    cancelOptions() {
      return {
        button: {
          text: this.$options.i18n.cancel,
          attributes: [{ disabled: this.loading }],
        },
        callback: this.resetForm,
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
        callback: this.createSegment,
      };
    },
    canSubmit() {
      return Boolean(this.selectedGroupId);
    },
    displayError() {
      return this.errors[0];
    },
    modalTitle() {
      return this.$options.i18n.addingTitle;
    },
    filteredOptions() {
      return this.filter
        ? this.checkboxOptions.filter((option) =>
            option.text.toLowerCase().includes(this.filter.toLowerCase()),
          )
        : this.checkboxOptions;
    },
  },
  methods: {
    async createSegment() {
      try {
        this.loading = true;
        const {
          data: {
            createDevopsAdoptionSegment: { errors },
          },
        } = await this.$apollo.mutate({
          mutation: createDevopsAdoptionSegmentMutation,
          variables: {
            namespaceId: convertToGraphQLId(TYPE_GROUP, this.selectedGroupId),
          },
          update: (store, { data }) => {
            const {
              createDevopsAdoptionSegment: { segment, errors: requestErrors },
            } = data;

            if (!requestErrors.length) addSegmentToCache(store, segment);
          },
        });

        if (errors.length) {
          this.errors = errors;
        } else {
          this.resetForm();
          this.closeModal();
        }
      } catch (error) {
        this.errors.push(this.$options.i18n.error);
        Sentry.captureException(error);
      } finally {
        this.loading = false;
      }
    },
    clearErrors() {
      this.errors = [];
    },
    closeModal() {
      this.$refs.modal.hide();
    },
    resetForm() {
      this.selectedGroupId = null;
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
    @canceled="cancelOptions.callback"
    @hide="resetForm"
    @show="$emit('trackModalOpenState', true)"
  >
    <gl-alert v-if="errors.length" variant="danger" class="gl-mb-3" @dismiss="clearErrors">
      {{ displayError }}
    </gl-alert>
    <gl-form-group class="gl-mb-3" data-testid="filter">
      <gl-icon name="search" :size="18" class="gl-text-gray-300 gl-absolute gl-mt-3 gl-ml-3" />
      <gl-form-input
        v-model="filter"
        class="gl-pl-7!"
        type="text"
        :placeholder="$options.i18n.filterPlaceholder"
        :disabled="loading"
      />
    </gl-form-group>
    <gl-form-group class="gl-mb-0">
      <gl-form-radio-group
        v-if="filteredOptions.length"
        :key="filteredOptions.length"
        v-model="selectedGroupId"
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
