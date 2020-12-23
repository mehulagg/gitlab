<script>
import { uniqueId } from 'lodash';
import {
  GlAlert,
  GlButton,
  GlModal,
  GlSkeletonLoader,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';

export default {
  components: {
    GlAlert,
    GlButton,
    GlModal,
    GlSkeletonLoader,
    GlTable,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    profiles: {
      type: Array,
      required: true,
    },
    tableLabel: {
      type: String,
      required: true,
    },
    fields: {
      type: Array,
      required: true,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
    errorDetails: {
      type: Array,
      required: false,
      default: () => [],
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    profilesPerPage: {
      type: Number,
      required: true,
    },
    hasMoreProfilesToLoad: {
      type: Boolean,
      required: false,
      default: false,
    },
    fullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      toBeDeletedProfileId: null,
    };
  },
  computed: {
    hasError() {
      return this.errorMessage !== '';
    },
    hasErrorDetails() {
      return this.errorDetails.length > 0;
    },
    hasProfiles() {
      return this.profiles.length > 0;
    },
    isLoadingInitialProfiles() {
      return this.isLoading && !this.hasProfiles;
    },
    shouldShowTable() {
      return this.isLoadingInitialProfiles || this.hasProfiles || this.hasError;
    },
    modalId() {
      return `dast-profiles-list-${uniqueId()}`;
    },
    tableFields() {
      const defaultClasses = ['gl-word-break-all'];
      const dataFields = this.fields.map((key) => ({ key, class: defaultClasses }));
      const staticFields = [{ key: 'actions' }];

      return [...dataFields, ...staticFields];
    },
  },
  methods: {
    handleDelete() {
      this.$emit('delete-profile', this.toBeDeletedProfileId);
    },
    prepareProfileDeletion(profileId) {
      this.toBeDeletedProfileId = profileId;
      this.$refs[this.modalId].show();
    },
    handleCancel() {
      this.toBeDeletedProfileId = null;
    },
  },
};
</script>
<template>
  <section>
    <div v-if="shouldShowTable">
      <gl-table
        :aria-label="tableLabel"
        :busy="isLoadingInitialProfiles"
        :fields="tableFields"
        :items="profiles"
        stacked="md"
        thead-class="gl-display-none"
      >
        <template v-if="hasError" #top-row>
          <td :colspan="tableFields.length">
            <gl-alert class="gl-my-4" variant="danger" :dismissible="false">
              {{ errorMessage }}
              <ul
                v-if="hasErrorDetails"
                :aria-label="__('DastProfiles|Error Details')"
                class="gl-p-0 gl-m-0"
              >
                <li v-for="errorDetail in errorDetails" :key="errorDetail">{{ errorDetail }}</li>
              </ul>
            </gl-alert>
          </td>
        </template>

        <template #cell(profileName)="{ value }">
          <strong>{{ value }}</strong>
        </template>

        <template v-for="slotName in Object.keys($scopedSlots)" #[slotName]="slotScope">
          <slot :name="slotName" v-bind="slotScope"></slot>
        </template>

        <template #cell(actions)="{ item }">
          <div class="gl-text-right">
            <slot name="actions" :profile="item"></slot>

            <gl-button
              v-if="item.editPath"
              :href="item.editPath"
              class="gl-ml-3 gl-my-1"
              size="small"
              >{{ __('Edit') }}</gl-button
            >

            <gl-button
              v-gl-tooltip.hover.focus
              icon="remove"
              variant="danger"
              category="secondary"
              size="small"
              class="gl-mx-3 gl-my-1"
              :title="s__('DastProfiles|Delete profile')"
              @click="prepareProfileDeletion(item.id)"
            />
          </div>
        </template>

        <template #table-busy>
          <div v-for="i in profilesPerPage" :key="i" data-testid="loadingIndicator">
            <gl-skeleton-loader :width="1248" :height="52">
              <rect x="0" y="16" width="300" height="20" rx="4" />
              <rect x="380" y="16" width="300" height="20" rx="4" />
              <rect x="770" y="16" width="300" height="20" rx="4" />
              <rect x="1140" y="11" width="50" height="30" rx="4" />
            </gl-skeleton-loader>
          </div>
        </template>
      </gl-table>

      <p v-if="hasMoreProfilesToLoad" class="gl-display-flex gl-justify-content-center">
        <gl-button
          data-testid="loadMore"
          :loading="isLoading && !hasError"
          @click="$emit('load-more-profiles')"
        >
          {{ __('Load more') }}
        </gl-button>
      </p>
    </div>

    <p v-else class="gl-my-4">
      {{ s__('DastProfiles|No profiles created yet') }}
    </p>

    <gl-modal
      :ref="modalId"
      :modal-id="modalId"
      :title="s__('DastProfiles|Are you sure you want to delete this profile?')"
      :ok-title="__('Delete')"
      :static="true"
      :lazy="true"
      ok-variant="danger"
      body-class="gl-display-none"
      @ok="handleDelete"
      @cancel="handleCancel"
    />

    <slot></slot>
  </section>
</template>
