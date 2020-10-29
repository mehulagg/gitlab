<script>
import CEMembersTableCell from '~/vue_shared/components/members/table/members_table_cell.vue';

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
      return this.member.canOverride;
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
