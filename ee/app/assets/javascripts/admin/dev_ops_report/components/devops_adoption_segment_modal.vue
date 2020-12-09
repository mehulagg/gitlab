<script>
import {
  GlFormGroup,
  GlFormInput,
  GlFormCheckboxTree,
  GlModal,
  GlSprintf,
  GlAlert,
  GlIcon,
} from '@gitlab/ui';
import { convertToGraphQLIds, TYPE_GROUP } from '~/graphql_shared/utils';
import * as Sentry from '~/sentry/wrapper';
import createDevopsAdoptionSegmentMutation from '../graphql/mutations/create_devops_adoption_segment.mutation.graphql';
import { DEVOPS_ADOPTION_STRINGS, DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from '../constants';
import { addSegmentToCache } from '../utils/cache_updates';

export default {
  name: 'DevopsAdoptionSegmentModal',
  components: {
    GlModal,
    GlFormGroup,
    GlFormInput,
    GlFormCheckboxTree,
    GlSprintf,
    GlAlert,
    GlIcon,
  },
  props: {
    segmentId: {
      type: String,
      required: false,
      default: null,
    },
    groups: {
      type: Array,
      required: true,
    },
  },
  i18n: DEVOPS_ADOPTION_STRINGS.modal,
  data() {
    return {
      filter: '',
      name: '',
      checkboxValues: [],
      loading: false,
      errors: [],
    };
  },
  computed: {
    checkboxOptions() {
      return this.groups.map(({ id, full_name }) => ({ label: full_name, value: id }));
    },
    cancelOptions() {
      return {
        text: this.$options.i18n.cancel,
        attributes: [{ disabled: this.loading }],
      };
    },
    primaryOptions() {
      return {
        text: this.$options.i18n.button,
        attributes: [
          {
            variant: 'info',
            loading: this.loading,
            disabled: !this.canSubmit,
          },
        ],
      };
    },
    canSubmit() {
      return this.name.length && this.checkboxValues.length;
    },
    displayError() {
      return this.errors[0];
    },
    filteredOptions() {
      return this.filter
        ? this.checkboxOptions.filter(option =>
            option.label.toLowerCase().includes(this.filter.toLowerCase()),
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
            name: this.name,
            groupIds: convertToGraphQLIds(TYPE_GROUP, this.checkboxValues),
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
          this.name = '';
          this.checkboxValues = [];

          this.$refs.modal.hide();
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
  },
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
};
</script>
<template>
  <gl-modal
    ref="modal"
    :modal-id="$options.devopsSegmentModalId"
    :title="$options.i18n.title"
    size="sm"
    scrollable
    :action-primary="primaryOptions"
    :action-cancel="cancelOptions"
    @primary.prevent="createSegment"
  >
    <gl-alert v-if="errors.length" variant="danger" class="gl-mb-3" @dismiss="clearErrors">
      {{ displayError }}
    </gl-alert>
    <gl-form-group :label="$options.i18n.nameLabel" label-for="name">
      <gl-form-input
        id="name"
        v-model="name"
        data-testid="name"
        type="text"
        :placeholder="$options.i18n.namePlaceholder"
        required
        :disabled="loading"
      />
    </gl-form-group>
    <gl-form-group class="gl-mb-3">
      <gl-icon name="search" :size="18" class="gl-text-gray-300 gl-absolute gl-mt-3 gl-ml-3" />
      <gl-form-input
        v-model="filter"
        data-testid="filter"
        class="gl-pl-7!"
        type="text"
        :placeholder="$options.i18n.filterPlaceholder"
        :disabled="loading"
      />
    </gl-form-group>
    <gl-form-group class="gl-mb-0">
      <gl-form-checkbox-tree
        v-if="filteredOptions.length"
        v-model="checkboxValues"
        data-testid="groups"
        :options="filteredOptions"
        :hide-toggle-all="true"
        :disabled="loading"
        class="gl-p-3 gl-pb-0 gl-mb-2 gl-border-1 gl-border-solid gl-border-gray-100 gl-rounded-base"
      />
      <gl-alert v-else variant="info" :dismissible="false">
        {{ $options.i18n.noResults }}
      </gl-alert>
      <div class="gl-text-gray-400" data-testid="groupsHelperText">
        <gl-sprintf
          :message="
            n__(
              $options.i18n.selectedGroupsTextSingular,
              $options.i18n.selectedGroupsTextPlural,
              checkboxValues.length,
            )
          "
        >
          <template #selectedCount>
            {{ checkboxValues.length }}
          </template>
        </gl-sprintf>
      </div>
    </gl-form-group>
  </gl-modal>
</template>
