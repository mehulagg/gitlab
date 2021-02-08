<script>
import { MAX_LIST_COUNT } from '../constants';
import getCorpusesQuery from '../graphql/queries/get_corpuses.query.graphql';

export default {
  apollo: {
    states: {
      query: getCorpusesQuery,
      variables() {
        return {
          projectPath: this.projectFullPath,
          ...this.cursor,
        }
      },
      update: (data) => data,
      error() {
        this.states = null;
      }
    }
  },
  props: {
    projectFullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      cursor: {
        first: MAX_LIST_COUNT,
        after: null,
        last: null,
        before: null,
      }
    }
  }
};
</script>

<template>
  <span>foo</span>
</template>
