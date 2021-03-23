<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapGetters } from 'vuex';
import { fullBoardId } from '~/boards/boards_util';
import BoardFormFoss from '~/boards/components/board_form.vue';
import { fullEpicBoardId } from '../boards_util';
import createEpicBoardMutation from '../graphql/epic_board_create.mutation.graphql';
import destroyEpicBoardMutation from '../graphql/epic_board_destroy.mutation.graphql';

export default {
  extends: BoardFormFoss,
  computed: {
    ...mapGetters(['isEpicBoard']),
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
        mutation: this.isEpicBoard ? createEpicBoardMutation : this.currentMutation,
        variables: { input: this.mutationVariables },
      });

      if (!this.board.id) {
        return this.isEpicBoard
          ? this.epicBoardCreateResponse(response.data)
          : this.boardCreateResponse(response.data);
      }

      return this.boardUpdateResponse(response.data);
    },
    async deleteBoard() {
      await this.$apollo.mutate({
        mutation: this.isEpicBoard ? destroyEpicBoardMutation : this.deleteMutation,
        variables: {
          id: this.isEpicBoard ? fullEpicBoardId(this.board.id) : fullBoardId(this.board.id),
        },
      });
    },
  },
};
</script>
