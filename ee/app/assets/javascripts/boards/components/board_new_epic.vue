<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapActions, mapGetters } from 'vuex';
import BoardNewIssueFoss from '~/boards/components/board_new_issue.vue';
import { toggleFormEventPrefix } from '~/boards/constants';
import eventHub from '~/boards/eventhub';
import createFlash from '~/flash';
import { __, s__ } from '~/locale';

import { fullEpicBoardId } from '../boards_util';

export default {
  extends: BoardNewIssueFoss,
  inject: {
    boardId: {
      default: '',
    },
  },
  computed: {
    ...mapGetters(['isGroupBoard']),
    submitButtonTitle() {
      return __('Create epic');
    },
    disabled() {
      return this.title === '';
    },
  },
  methods: {
    ...mapActions(['addListNewEpic']),
    submit() {
      const {
        title,
        boardId,
        list: { id },
      } = this;

      eventHub.$emit(`scroll-board-list-${id}`);

      this.addListNewEpic({
        epicInput: {
          title,
          boardId: fullEpicBoardId(boardId),
          listId: id,
        },
        list: this.list,
      })
        .then(() => {
          this.reset();
        })
        .catch((error) => {
          createFlash({
            message: s__('Board|Failed to create epic. Please try again.'),
            captureError: true,
            error,
          });
        });
    },
    reset() {
      this.title = '';
      eventHub.$emit(`${toggleFormEventPrefix.epic}${this.list.id}`);
    },
  },
};
</script>
