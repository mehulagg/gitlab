<script>
import { uniqueId } from 'lodash';
import {
  GlAlert,
  GlButton,
  GlModal,
  GlSkeletonLoader,
  GlTable,
  GlTooltipDirective,
  GlDropdown,
  GlDropdownItem,
  GlIcon,
} from '@gitlab/ui';
import { visitUrl } from '~/lib/utils/url_utility';

export default {
  components: {
    GlAlert,
    GlButton,
    GlModal,
    GlSkeletonLoader,
    GlTable,
    GlDropdown,
    GlDropdownItem,
    GlIcon,
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
      const defaultThClasses = ['gl-bg-transparent!', 'gl-text-black-normal'];

      const dataFields = this.fields.map(({ key, label }) => ({
        key,
        label,
        class: defaultClasses,
        thClass: defaultThClasses,
      }));

      const staticFields = [{ key: 'actions', label: '', thClass: defaultThClasses }];

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
    navigateToProfile({ editPath }) {
      return visitUrl(editPath);
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
        fixed
        hover
        thead-class="gl-border-b-solid gl-border-gray-100 gl-border-1 gl-pt-3!"
        tbody-tr-class="gl-hover-cursor-pointer gl-hover-bg-blue-50!"
        @row-clicked="navigateToProfile"
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
          <div class="gl-overflow-hidden gl-white-space-nowrap gl-text-overflow-ellipsis">
            {{ value }}
          </div>
        </template>

        <template v-for="slotName in Object.keys($scopedSlots)" #[slotName]="slotScope">
          <slot :name="slotName" v-bind="slotScope"></slot>
        </template>

        <template #cell(actions)="{ item }">
          <div class="gl-text-right">
            <slot name="actions" :profile="item"></slot>

            <gl-dropdown
              class="gl-display-none gl-md-display-inline-flex!"
              toggle-class="gl-border-0! gl-shadow-none!"
              no-caret
              right
              category="tertiary"
            >
              <template #button-content>
                <gl-icon name="ellipsis_v" />
                <span class="gl-sr-only">{{ __('Actions') }}</span>
              </template>

              <gl-dropdown-item
                v-if="item.editPath"
                :href="item.editPath"
                :title="s__('DastProfiles|Edit profile')"
                >{{ __('Edit') }}</gl-dropdown-item
              >

              <gl-dropdown-item
                variant="danger"
                :title="s__('DastProfiles|Delete profile')"
                @click="prepareProfileDeletion(item.id)"
              >
                {{ __('Delete') }}
              </gl-dropdown-item>
            </gl-dropdown>
            <gl-button
              v-if="item.editPath"
              :href="item.editPath"
              category="tertiary"
              class="gl-ml-3 gl-my-1 gl-display-md-none"
              size="small"
              >{{ __('Edit') }}</gl-button
            >
            <gl-button
              v-gl-tooltip.hover.focus
              category="tertiary"
              icon="remove"
              variant="danger"
              size="small"
              class="gl-mx-3 gl-my-1 gl-display-md-none"
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
