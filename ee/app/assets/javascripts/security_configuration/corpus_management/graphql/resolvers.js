import Api from 'ee/api';

export default {
  Package: {
    restPackages: (state) => {
      return state.restPackages || [];
    },
    mockedPackages: (state) => {
      return state.mockedPackages || [];
    }
  },
  Query: {
    restPackages: (_, {projectPath}) => {
      // Data from REST endpoint
      return Api.fetchPackages(projectPath).then(({data}) => ({
        data,
        __typename: 'RestPackages',
      }));
    },
    mockedPackages(_, {projectPath}) {
      return {
        // Mocked data goes here
        data: [{name: 'Foo'}, {name: 'Bar'}],
        __typename: 'MockedPackages'
      }
    }
  }
}