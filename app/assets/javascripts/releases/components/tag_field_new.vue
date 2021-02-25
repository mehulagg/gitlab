<script>
import { GlFormGroup, GlFormInput, GlDropdownItem, GlSprintf } from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { mapState, mapActions, mapGetters } from 'vuex';
import { __ } from '~/locale';
import RefSelector from '~/ref/components/ref_selector.vue';
import FormFieldContainer from './form_field_container.vue';

export default {
  name: 'TagFieldNew',
  components: {
    GlFormGroup,
    GlFormInput,
    RefSelector,
    FormFieldContainer,
    GlDropdownItem,
    GlSprintf,
  },
  data() {
    return {
      // Keeps track of whether or not the user has interacted with
      // the input field. This is used to avoid showing validation
      // errors immediately when the page loads.
      isInputDirty: false,
      matches: null,
      areTagsLoading: false,
      tagsSearchQuery: '',
      showCreateFrom: true,
    };
  },
  computed: {
    ...mapState('detail', ['projectId', 'release', 'createFrom']),
    ...mapGetters('detail', ['validationErrors']),
    tagName: {
      get() {
        return this.release.tagName;
      },
      set(tagName) {
        this.updateReleaseTagName(tagName);
        this.showCreateFrom = true;
      },
    },
    createFromModel: {
      get() {
        return this.createFrom;
      },
      set(createFrom) {
        this.updateCreateFrom(createFrom);
      },
    },
    showTagNameValidationError() {
      return this.isInputDirty && this.validationErrors.isTagNameEmpty;
    },
    tagNameInputId() {
      return uniqueId('tag-name-input-');
    },
    createFromSelectorId() {
      return uniqueId('create-from-selector-');
    },
  },
  methods: {
    ...mapActions('detail', ['updateReleaseTagName', 'updateCreateFrom']),
    markInputAsDirty() {
      this.isInputDirty = true;
    },
    createTagClicked(newTagName) {
      this.tagName = newTagName;
      this.showCreateFrom = false;
    },
  },
  translations: {
    tagName: {
      noRefSelected: __('No tag selected'),
      dropdownHeader: __('Tag name'),
      searchPlaceholder: __('Search or create tag'),
    },
    createFrom: {
      noRefSelected: __('No source selected'),
      searchPlaceholder: __('Search branches, tags, and commits'),
      dropdownHeader: __('Select source'),
    },
  },
};
</script>
<template>
  <div>
    <gl-form-group
      :label="__('Tag name')"
      :label-for="tagNameInputId"
      data-testid="tag-name-field"
      :state="!showTagNameValidationError"
      :invalid-feedback="__('Tag name is required')"
    >
      <form-field-container>
        <!-- <gl-form-input
          :id="tagNameInputId"
          v-model="tagName"
          :state="!showTagNameValidationError"
          type="text"
          class="form-control"
          @blur.once="markInputAsDirty"
        /> -->
        <ref-selector
          :id="tagNameInputId"
          v-model="tagName"
          :project-id="projectId"
          :translations="$options.translations.tagName"
          :ref-types="['tags']"
          @matches-updated="matches = $event"
          @is-loading-updated="areTagsLoading = $event"
          @query-updated="tagsSearchQuery = $event"
        >
          <template #footer v-if="!areTagsLoading && matches && matches.tags.totalCount === 0">
            <gl-dropdown-item
              @click="createTagClicked(tagsSearchQuery)"
              is-check-item
              :is-checked="tagName === tagsSearchQuery"
            >
              <gl-sprintf :message="__('Create tag %{tagName}')">
                <template #tagName>
                  <b>{{ tagsSearchQuery }}</b>
                </template>
              </gl-sprintf>
            </gl-dropdown-item>
          </template>
        </ref-selector>
      </form-field-container>
    </gl-form-group>
    <gl-form-group
      v-if="showCreateFrom"
      :label="__('Create from')"
      :label-for="createFromSelectorId"
      data-testid="create-from-field"
    >
      <form-field-container>
        <ref-selector
          :id="createFromSelectorId"
          v-model="createFromModel"
          :project-id="projectId"
          :translations="$options.translations.translations"
        />
      </form-field-container>
      <template #description>
        {{ __('Existing branch name, tag, or commit SHA') }}
      </template>
    </gl-form-group>
  </div>
</template>
