<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import { mapActions } from 'vuex';
import BoardNewIssueFoss from '~/boards/components/board_new_issue.vue';
import eventHub from '~/boards/eventhub';
import { __ } from '~/locale';

import { fullEpicBoardId } from '../boards_util';

export default {
  extends: BoardNewIssueFoss,
  inject: {
    boardId: {
      default: '',
    },
  },
  computed: {
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
      const { title, boardId } = this;
      const { id } = this.list;

      eventHub.$emit(`scroll-board-list-${this.list.id}`);

      return this.addListNewEpic({
        epicInput: {
          title,
          boardId: fullEpicBoardId(boardId),
          listId: id,
        },
        list: this.list,
      }).then(() => {
        this.reset();
      });
    },
    reset() {
      this.title = '';
      eventHub.$emit(`toggle-epic-form-${this.list.id}`);
    },
  },
};
</script>
