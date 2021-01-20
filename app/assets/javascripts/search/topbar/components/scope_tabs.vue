<script>
  export default {
    name: 'ScopeTabs',
    props: {
      scopeTabs: {
        type: Object,
        required: false,
        default: () => ([]),
      },
    },
    mounted() {
      const url = `${scopeTabs[0].url}`

      return api
        .get(url)
        .then(({ data }) => showCount(el, data.count))
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.error(`Failed to fetch search count from '${url}'.`, e);
        });
    }
  }
</script>

<template>
  <div>
    <gl-tabs v-for="tabs in scopeTabs"/>
  </div>
</template>
