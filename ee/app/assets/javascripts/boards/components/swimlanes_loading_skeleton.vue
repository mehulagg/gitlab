<script>
import BoardCardLoadingSkeleton from '~/boards/components/board_card_loading_skeleton.vue';

export default {
  components: {
    BoardCardLoadingSkeleton,
  },
};
</script>

<template>
  <div class="gl-px-3">
    <div v-for="i in 3" :key="i" class="gl-mt-6 gl-bg-gray-100 gl-display-flex gl-rounded-base">
      <div v-for="j in 4" :key="j" class="gl-px-3 gl-pt-3">
        <board-card-loading-skeleton />
      </div>
    </div>
  </div>
</template>
