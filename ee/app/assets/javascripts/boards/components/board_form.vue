<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapState } from 'vuex';
import BoardFormFoss from '~/boards/components/board_form.vue';
import { fullEpicBoardId } from '../boards_util';
import createEpicBoardMutation from '../graphql/epic_board_create.mutation.graphql';
import updateEpicBoardMutation from '../graphql/epic_board_update.mutation.graphql';

export default {
  extends: BoardFormFoss,
  computed: {
    ...mapState(['isEpicBoard']),
    currentEpicBoardMutation() {
      return this.board.id ? updateEpicBoardMutation : createEpicBoardMutation;
    },
    mutationVariables() {
      const { board } = this;

      return {
        ...this.baseMutationVariables,
        ...(board.id && this.isEpicBoard && { id: fullEpicBoardId(board.id) }),
        ...(this.scopedIssueBoardFeatureEnabled || this.isEpicBoard
          ? this.boardScopeMutationVariables
          : {}),
      };
    },
  },
  methods: {
    epicBoardCreateResponse(data) {
      return data.epicBoardCreate.epicBoard.webPath;
    },
    epicBoardUpdateResponse(data) {
      return data.epicBoardUpdate.epicBoard.webPath;
    },
    async createOrUpdateBoard() {
      const response = await this.$apollo.mutate({
        mutation: this.isEpicBoard ? this.currentEpicBoardMutation : this.currentMutation,
        variables: { input: this.mutationVariables },
      });

      if (!this.board.id) {
        return this.isEpicBoard
          ? this.epicBoardCreateResponse(response.data)
          : this.boardCreateResponse(response.data);
      }

      return this.isEpicBoard
        ? this.epicBoardUpdateResponse(response.data)
        : this.boardUpdateResponse(response.data);
    },
  },
};
</script>
