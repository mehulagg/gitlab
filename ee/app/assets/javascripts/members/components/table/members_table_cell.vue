<script>
import CEMembersTableCell from '~/members/components/table/members_table_cell.vue';
import { canOverride } from '../../utils';

export default {
  name: 'MembersTableCell',
  props: {
    member: {
      type: Object,
      required: true,
    },
  },
  computed: {
    canOverride() {
      return canOverride(this.member);
    },
  },
  render(createElement) {
    return createElement(CEMembersTableCell, {
      props: { member: this.member },
      scopedSlots: {
        default: props => {
          return this.$scopedSlots.default({
            ...props,
            permissions: {
              ...props.permissions,
              canOverride: this.canOverride,
            },
          });
        },
      },
    });
  },
};
</script>
