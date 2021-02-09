<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapState } from 'vuex';
import BoardsSelectorFoss from '~/boards/components/boards_selector.vue';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import epicBoardsQuery from '../graphql/epic_boards.query.graphql';

export default {
  extends: BoardsSelectorFoss,
  computed: {
    ...mapState(['isEpicBoard', 'fullPath']),
  },
  methods: {
    loadBoards(toggleDropdown = true) {
      if (toggleDropdown && this.boards.length > 0) {
        return;
      }

      if (this.isEpicBoard) {
        this.$apollo.addSmartQuery('boards', {
          variables() {
            return { fullPath: this.fullPath };
          },
          query() {
            return epicBoardsQuery;
          },
          loadingKey: 'loadingBoards',
          update(data) {
            if (!data?.group) {
              return [];
            }
            return data.group.epicBoards.nodes.map((node) => ({
              id: getIdFromGraphQLId(node.id),
              name: node.name,
            }));
          },
        });
      } else {
        BoardsSelectorFoss.methods.loadBoards.call(this);
      }
    },
  },
};
</script>
