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
  },
  computed: {
    graphQlData() {
      const packages = this.states?.project.packages.nodes;
      debugger;
      return packages;
    },
     restData() {
       const packages = this.states?.restPackages.data;
       debugger;
      return packages;
    },
    mockedData() {
      const packages = this.states?.mockedPackages.data;
      debugger;
      return packages;
    },       
  }
};
</script>

<template>
  <div>
    <div>GraphQL: {{graphQlData}}</div>
    <div>REST: {{restData}}</div>
    <div>Mocked: {{mockedData}}</div>
  </div>
</template>
