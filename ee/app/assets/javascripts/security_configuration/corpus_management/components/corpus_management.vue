<script>
import { GlLoadingIcon, GlLink } from '@gitlab/ui';
import CorpusTable from 'ee/security_configuration/corpus_management/components/corpus_table.vue';
import CorpusUpload from 'ee/security_configuration/corpus_management/components/corpus_upload.vue';
import { s__, __ } from '~/locale';
import { MAX_LIST_COUNT } from '../constants';
import getCorpusesQuery from '../graphql/queries/get_corpuses.query.graphql';

export default {
  components: {
    GlLoadingIcon,
    GlLink,
    CorpusTable,
    CorpusUpload,
  },
  apollo: {
    states: {
      query: getCorpusesQuery,
      variables() {
        return {
          projectPath: this.projectFullPath,
          ...this.cursor,
        };
      },
      update: (data) => {
        return data;
      },
      error() {
        this.states = null;
      },
    },
  },
  props: {
    projectFullPath: {
      type: String,
      required: true,
    },
    corpusHelpPath: {
      type: String,
      required: true,
      // TODO: Remove mocked out docs path used for demo
      default: 'https://docs.gitlab.com/ee/user/application_security/coverage_fuzzing/',
    },
  },
  i18n: {
    header: s__('CorpusManagement|Fuzz testing corpus management'),
    subHeader: s__(
      'CorpusManagement|Corpus are used in fuzz testing as mutation source to Improve future testing.',
    ),
    learnMore: __('Learn More'),
  },
  data() {
    return {
      cursor: {
        first: MAX_LIST_COUNT,
        after: null,
        last: null,
        before: null,
      },
    };
  },
  computed: {
    graphQlData() {
      const packages = this.states?.project.packages.nodes;
      return packages;
    },
    restData() {
      const packages = this.states?.restPackages.data;
      return packages;
    },
    mockedData() {
      const packages = this.states?.mockedPackages.data || [];
      return packages;
    },
    isLoading() {
      return this.$apollo.loading;
    },
    totalSize() {
      return this.states?.mockedPackages.totalSize;
    },
  },
};
</script>

<template>
  <div>
    <header>
      <h4 class="gl-my-5">
        {{ this.$options.i18n.header }}
      </h4>
      <h5 class="gl-font-base gl-font-weight-100">
        {{ this.$options.i18n.subHeader }}
        <gl-link :href="corpusHelpPath">{{ this.$options.i18n.learnMore }}</gl-link>
      </h5>
    </header>

    <gl-loading-icon v-if="isLoading" size="lg" />
    <template v-else>
      <corpus-upload :total-size="totalSize" />
      <corpus-table :corpuses="mockedData" :project-full-path="projectFullPath" />
    </template>
  </div>
</template>
