<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapGetters } from 'vuex';
import BoardFormFoss from '~/boards/components/board_form.vue';
import createEpicBoardMutation from '../graphql/epic_board_create.mutation.graphql';

export default {
  extends: BoardFormFoss,
  computed: {
    ...mapGetters(['isEpicBoard']),
    epicBoardCreateQuery() {
      return createEpicBoardMutation;
    },
    mutationVariables() {
      // TODO: Epic board scope will be added in a future iteration: https://gitlab.com/gitlab-org/gitlab/-/issues/231389
      return {
        ...this.baseMutationVariables,
        ...(this.scopedIssueBoardFeatureEnabled && !this.isEpicBoard
          ? this.boardScopeMutationVariables
          : {}),
      };
    },
  },
  methods: {
    epicBoardCreateResponse(data) {
      return data.epicBoardCreate.epicBoard.webPath;
    },
    async createOrUpdateBoard() {
      const response = await this.$apollo.mutate({
        mutation: this.isEpicBoard ? this.epicBoardCreateQuery : this.currentMutation,
        variables: { input: this.mutationVariables },
      });

      if (!this.board.id) {
        return this.isEpicBoard
          ? this.epicBoardCreateResponse(response.data)
          : this.boardCreateResponse(response.data);
      }

      return this.boardUpdateResponse(response.data);
    },
  },
};
</script>
