<script>
import { mapActions } from 'vuex';
import { fetchPolicies } from '~/lib/graphql';
import { confidentialityQueries } from '~/sidebar/constants';
import { defaultClient as gqlClient } from '~/sidebar/graphql';
import * as constants from '../constants';

export default {
  props: {
    noteableData: {
      type: Object,
      required: true,
    },
    iid: {
      type: Number,
      required: true,
    },
  },
  computed: {
    fullPath() {
      if (this.noteableData?.web_url) {
        return this.noteableData?.web_url.split('/-/')[0].substring(1);
      }
      return null;
    },
    issuableType() {
      return this.noteableData.noteableType.toLowerCase();
    },
  },
  created() {
    if (this.issuableType !== IssuableType.Issue) {
      return;
    }

    gqlClient
      .watchQuery({
        query: confidentialityQueries[this.issuableType].query,
        variables: {
          iid: this.iid.toString(10),
          fullPath: this.fullPath,
        },
        fetchPolicy: fetchPolicies.CACHE_ONLY,
      })
      .subscribe((res) => {
        const issuable = res.data?.workspace?.issuable;
        if (issuable) {
          this.setConfidentiality(res.data.workspace.issuable.confidential);
        }
      });
  },
  methods: {
    ...mapActions(['setConfidentiality']),
  },
  render() {
    return null;
  },
};
</script>
