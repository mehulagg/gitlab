<script>
import TopNavContainerView from './top_nav_container_view.vue';
import TopNavSubviewHeader from './top_nav_subview_header.vue';

export default {
  components: {
    TopNavContainerView,
    TopNavSubviewHeader,
  },
  props: {
    headerTitle: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <top-nav-subview-header>{{ headerTitle }}</top-nav-subview-header>
    <top-nav-container-view frequent-items-container-class="gl-px-4" v-bind="$attrs" />
  </div>
</template>
