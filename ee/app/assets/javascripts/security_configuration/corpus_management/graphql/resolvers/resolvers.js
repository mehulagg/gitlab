import Package from './fragments/state.fragment.graphql';
import axios from '~/lib/utils/axios_utils';

export default {
  Package: {
    restPackages: (state) => {
      return state.restPackages || [];
    }
  },
  Query: {
    restPackages(_, {projectPath}) {
      return {
        __typename: 'RestPackages',
      };
    }
  }
}