<script>
import Tribute from 'tributejs';
import axios from '~/lib/utils/axios_utils';
import SidebarMediator from '~/sidebar/sidebar_mediator';
import { GfmAutocomplete, tributeConfig } from '~/vue_shared/components/gfm_autocomplete/utils';

export default {
  props: {
    autocompleteTypes: {
      type: Array,
      required: false,
      default: () => Object.values(GfmAutocomplete),
    },
    dataSources: {
      type: Object,
      required: false,
      default: () => gl.GfmAutoComplete?.dataSources || {},
    },
  },
  computed: {
    config() {
      return this.autocompleteTypes.map(type => ({
        ...tributeConfig[type].config,
        values: this.getValues(type),
      }));
    },
  },
  mounted() {
    this.tribute = new Tribute({ collection: this.config });

    const input = this.$slots.default?.[0]?.elm;
    this.tribute.attach(input);
  },
  beforeDestroy() {
    const input = this.$slots.default?.[0]?.elm;
    this.tribute.detach(input);
  },
  methods: {
    cacheAssignees() {
      const isAssigneesLengthSame =
        this.assignees?.length === SidebarMediator.singleton?.store?.assignees?.length;

      if (!this.assignees || !isAssigneesLengthSame) {
        this.assignees =
          SidebarMediator.singleton?.store?.assignees?.map(assignee => assignee.username) || [];
      }
    },
    filterValues(type) {
      // The assignees AJAX response can come after the user first invokes autocomplete
      // so we need to check more than once if we need to update the assignee cache
      this.cacheAssignees();

      return tributeConfig[type].filterValues
        ? tributeConfig[type].filterValues({
            assignees: this.assignees,
            collection: this[type],
            fullText: this.$slots.default?.[0]?.elm?.value,
            selectionStart: this.$slots.default?.[0]?.elm?.selectionStart,
          })
        : this[type];
    },
    getValues(type) {
      return (inputText, processValues) => {
        if (this[type]) {
          processValues(this.filterValues(type));
        } else if (this.dataSources[type]) {
          axios
            .get(this.dataSources[type])
            .then(response => {
              this[type] = response.data;
              processValues(this.filterValues(type));
            })
            .catch(() => {});
        } else {
          processValues([]);
        }
      };
    },
  },
  render(createElement) {
    return createElement('div', this.$slots.default);
  },
};
</script>
