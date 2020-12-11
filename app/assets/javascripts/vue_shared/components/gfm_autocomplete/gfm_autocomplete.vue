<script>
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Tribute from 'tributejs';
import {
  GfmAutocompleteType,
  tributeConfig,
} from 'ee_else_ce/vue_shared/components/gfm_autocomplete/utils';
import createFlash from '~/flash';
import createGqClient, { fetchPolicies } from '~/lib/graphql';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import SidebarMediator from '~/sidebar/sidebar_mediator';
import iterationTitleSearchQuery from './queries/iteration_title_search.query.graphql';

Vue.use(VueApollo);

const gqlClient = createGqClient(
  {},
  {
    fetchPolicy: fetchPolicies.NO_CACHE,
  },
);

export default {
  errorMessage: __(
    'An error occurred while getting autocomplete data. Please refresh the page and try again.',
  ),
  inject: {
    groupPath: {
      default: '',
    },
  },
  props: {
    autocompleteTypes: {
      type: Array,
      required: false,
      default: () => Object.values(GfmAutocompleteType),
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
    this.cache = {};
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
            collection: this.cache[type],
            fullText: this.$slots.default?.[0]?.elm?.value,
            selectionStart: this.$slots.default?.[0]?.elm?.selectionStart,
          })
        : this.cache[type];
    },
    getValues(type) {
      return (inputText, processValues) => {
        if (type === GfmAutocompleteType.Iterations && this.groupPath) {
          return gqlClient
            .query({
              query: iterationTitleSearchQuery,
              variables: {
                title: inputText,
                groupPath: this.groupPath,
              },
            })
            .then(({ data }) => processValues(data.group?.iterations?.nodes || []))
            .catch(() => createFlash({ message: this.$options.errorMessage }));
        }

        if (this.cache[type]) {
          return processValues(this.filterValues(type));
        }

        if (this.dataSources[type]) {
          return axios
            .get(this.dataSources[type])
            .then(({ data }) => {
              this.cache[type] = data;
              processValues(this.filterValues(type));
            })
            .catch(() => createFlash({ message: this.$options.errorMessage }));
        }

        return processValues([]);
      };
    },
  },
  render(createElement) {
    return createElement('div', this.$slots.default);
  },
};
</script>
