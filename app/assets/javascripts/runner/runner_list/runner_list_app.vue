<script>
// import Api from '~/api';
import getRunnersQuery from '../graphql/get_runners.query.graphql';

export default {
  data() {
    return {
      runners: [],
    };
  },
  // mounted() {
  //   this.getRunners();
  // },
  // methods: {
  //   async getRunners() {
  //     const { data } = await Api.getRunners();
  //     this.runners = data;
  //   },
  // },
  apollo: {
    runners: {
      query: getRunnersQuery,
      update(data) {
        return data.runners;
      },
    },
  },
};
</script>
<template>
  <div>
    <ul class="content-list">
      <li v-for="runner in runners" :key="runner.id" class="gl-px-3 gl-py-3">
        <div class="gl-display-flex">
          <div class="gl-flex-grow-1 gl-flex-shrink-1 gl-mr-3">
            <div class="gl-font-weight-bold">
              <span>#{{ runner.id }}</span>
            </div>
            <div>
              {{ runner.description }}
            </div>
          </div>
          <div class="gl-flex-grow-1 gl-flex-shrink-0"></div>
        </div>
      </li>
    </ul>
    <pre>{{ runners }}</pre>
  </div>
</template>
