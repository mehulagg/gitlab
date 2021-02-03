<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapState } from 'vuex';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import BoardsSelectorFoss from '~/boards/components/boards_selector.vue';
import projectQuery from '~/boards/graphql/project_boards.query.graphql';
import groupQuery from '~/boards/graphql/group_boards.query.graphql';
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
        this.$apollo.addSmartQuery('boards', {
          variables() {
            return { fullPath: this.fullPath };
          },
          query() {
            return this.groupId ? groupQuery : projectQuery;
          },
          loadingKey: 'loadingBoards',
          update(data) {
            if (!data?.[this.parentType]) {
              return [];
            }
            return data[this.parentType].boards.edges.map(({ node }) => ({
              id: getIdFromGraphQLId(node.id),
              name: node.name,
            }));
          },
        });
      }
    },
  },
};
</script>
