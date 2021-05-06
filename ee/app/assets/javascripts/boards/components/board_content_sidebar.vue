<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import BoardContentSidebarFoss from '~/boards/components/board_content_sidebar.vue';

export default {
  extends: BoardContentSidebarFoss,
  computed: {
    showEpicSelector() {
      return true;
    },
    showIterationSelector() {
      return true;
    },
    showWeightSelector() {
      return true;
    },
  },
};
</script>
