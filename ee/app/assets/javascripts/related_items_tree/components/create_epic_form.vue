<script>
import { mapState, mapActions } from 'vuex';
import { debounce } from 'lodash';

import { GlButton, GlDropdown, GlSearchBoxByType, GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { SEARCH_DEBOUNCE } from '../constants';

import { __ } from '~/locale';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlSearchBoxByType,
    GlDropdownItem,
    ProjectAvatar,
    GlLoadingIcon,
  },
  props: {
    isSubmitting: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      inputValue: '',
      searchTerm: '',
      selectedGroup: null,
    };
  },
  computed: {
    ...mapState([
      'descendantGroupsFetchInProgress',
      'itemCreateInProgress',
      'descendantGroups',
      'parentItem',
    ]),
    isSubmitButtonDisabled() {
      return this.inputValue.length === 0 || this.isSubmitting;
    },
    buttonLabel() {
      return this.isSubmitting ? __('Creating epic') : __('Create epic');
    },
    dropdownPlaceholderText() {
      return this.selectedGroup?.name || __('Search a group');
    },
    canRenderNoResults() {
      return !this.descendantGroupsFetchInProgress && !this.descendantGroups?.length;
    },
    canRenderSearchResults() {
      return !this.descendantGroupsFetchInProgress;
    },
  },
  watch: {
    searchTerm: debounce(function debounceSearch() {
      this.handleDropdownShow();
    }, SEARCH_DEBOUNCE),

    descendantGroupsFetchInProgress(value) {
      if (!value) {
        this.$nextTick(() => {
          this.$refs.searchInputField.focusInput();
        });
      }
    },
  },
  mounted() {
    this.$nextTick()
      .then(() => {
        this.$refs.input.focus();
      })
      .catch(() => {});
  },

  methods: {
    ...mapActions(['fetchDescendantGroups']),
    onFormSubmit() {
      const groupFullPath = this.selectedGroup?.full_path;
      this.$emit('createEpicFormSubmit', this.inputValue.trim(), groupFullPath);
    },
    onFormCancel() {
      this.$emit('createEpicFormCancel');
    },
    handleDropdownShow() {
      const {
        parentItem: { groupId },
        searchTerm,
      } = this;
      this.fetchDescendantGroups({ groupId, search: searchTerm });
    },
  },
};
</script>

<template>
  <form @submit.prevent="onFormSubmit">
    <div class="row mb-3">
      <div class="col-sm">
        <label class="label-bold">{{ s__('Issue|Title') }}</label>
        <input
          ref="input"
          v-model="inputValue"
          :placeholder="
            parentItem.confidential ? __('New confidential epic title ') : __('New epic title')
          "
          type="text"
          class="form-control"
          @keyup.escape.exact="onFormCancel"
        />
      </div>
      <div class="col-sm">
        <label class="label-bold">{{ __('Group') }}</label>

        <gl-dropdown
          block
          :text="dropdownPlaceholderText"
          class="dropdown-descendant-groups"
          @show="handleDropdownShow"
          @hide="handleDropdownHide"
        >
          <gl-search-box-by-type
            ref="searchInputField"
            v-model.trim="searchTerm"
            :disabled="descendantGroupsFetchInProgress"
          />

          <gl-loading-icon
            v-show="descendantGroupsFetchInProgress"
            class="projects-fetch-loading align-items-center p-2"
            size="md"
          />

          <template v-if="canRenderSearchResults">
            <gl-dropdown-item
              v-for="group in descendantGroups"
              :key="group.id"
              class="w-100"
              @click="selectedGroup = group"
            >
              <project-avatar :project="group" :size="32" />
              {{ group.name }}
              <div class="text-secondary">{{ group.path }}</div>
            </gl-dropdown-item>
          </template>

          <gl-dropdown-item v-if="canRenderNoResults">{{
            __('No matching results')
          }}</gl-dropdown-item>
        </gl-dropdown>
      </div>
    </div>

    <div class="add-issuable-form-actions clearfix">
      <gl-button
        :disabled="isSubmitButtonDisabled"
        :loading="isSubmitting"
        variant="success"
        category="primary"
        type="submit"
        class="float-left"
      >
        {{ buttonLabel }}
      </gl-button>
      <gl-button class="float-right" @click="onFormCancel">{{ __('Cancel') }}</gl-button>
    </div>
  </form>
</template>
