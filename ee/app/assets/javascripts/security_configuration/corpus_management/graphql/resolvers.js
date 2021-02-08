import Api from 'ee/api';

export default {
  Package: {
    restPackages: (state) => {
      return state.restPackages || [];
    }
  },
  Query: {
    restPackages(_, {projectPath}) {
      debugger;
      return {
        data: Api.fetchPackages(projectPath).then(({data}) => {
          debugger;
          return data;
        }),
        __typename: 'RestPackages',
      };
    }
  }
}