<script>
import { mapState, mapActions } from 'vuex';
import { GlForm, GlSearchBoxByType, GlButton } from '@gitlab/ui';
import GroupFilter from './group_filter.vue';
import ProjectFilter from './project_filter.vue';

export default {
  name: 'SearchTopbarApp',
  components: {
    GlForm,
    GlSearchBoxByType,
    GroupFilter,
    ProjectFilter,
    GlButton,
  },
  props: {
    groupInitialData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    projectInitialData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    ...mapState(['query']),
    search: {
      get() {
        return this.query ? this.query.search : '';
      },
      set(value) {
        this.setQuery({ key: 'search', value });
      },
    },
  },
  methods: {
    ...mapActions(['applyQuery', 'setQuery']),
  },
};
</script>

<template>
  <gl-form class="search-page-form" @submit.prevent="applyQuery">
    <section class="d-lg-flex gl-align-items-flex-end">
      <div class="gl-flex-fill-1 gl-mb-4 gl-lg-mb-0 mr-lg-1">
        <label>{{ __('What are you searching for?') }}</label>
        <gl-search-box-by-type
          v-model="search"
          :placeholder="__(`Search for projects, issues, etc.`)"
        />
      </div>
      <div class="gl-mb-4 gl-lg-mb-0 mx-lg-1">
        <label class="gl-display-block">{{ __('Group') }}</label>
        <group-filter :initial-data="groupInitialData" />
      </div>
      <div class="gl-mb-4 gl-lg-mb-0 mx-lg-1">
        <label class="gl-display-block">{{ __('Project') }}</label>
        <project-filter :initial-data="projectInitialData" />
      </div>
      <gl-button class="btn-search" variant="success" type="submit">{{ __('Search') }}</gl-button>
    </section>
  </gl-form>
</template>
