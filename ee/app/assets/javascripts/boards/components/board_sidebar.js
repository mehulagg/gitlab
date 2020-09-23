import Weight from 'ee/sidebar/components/weight/weight.vue';
import BoardSidebar from '~/boards/components/board_sidebar';
import RemoveBtn from './sidebar/remove_issue';

export default BoardSidebar.extend({
  components: {
    RemoveBtn,
    Weight,
  },
});
