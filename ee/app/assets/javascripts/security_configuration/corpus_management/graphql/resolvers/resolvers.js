import produce from 'immer';
import Api from 'ee/api';
import { corpuses } from 'ee_jest/security_configuration/corpus_management/mock_data';
import getCorpusesQuery from './queries/get_corpuses.query.graphql';

export default {
  Package: {
    restPackages: (state) => {
      return state.restPackages || [];
    },
    mockedPackages: (state) => {
      return state.mockedPackages || [];
    },
  },
  Query: {
    restPackages: (_, { projectPath }) => {
      // Data from REST endpoint
      return Api.fetchPackages(projectPath).then(({ data }) => ({
        data,
        __typename: 'RestPackages',
      }));
    },
    /* eslint-disable no-unused-vars */
    mockedPackages(_, { projectPath }) {
      return {
        // Mocked data goes here
        totalSize: 20.45e8,
        data: corpuses,
        __typename: 'MockedPackages',
      };
    },
  },
  Mutation: {
    deleteCorpus: (_, { name, projectPath }, { cache }) => {
      const cursor = {
        first: 25,
        after: null,
        last: null,
        before: null,
      };

      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath, ...cursor },
      });

      const data = produce(sourceData, (draftState) => {
        const mockedCorpuses = draftState.mockedPackages;
        // Filter out deleted corpus
        mockedCorpuses.data = mockedCorpuses.data.filter((corpus) => {
          return corpus.name !== name;
        });
        // Re-compute total file size
        mockedCorpuses.totalSize = mockedCorpuses.data.reduce((totalSize, corpus) => {
          return totalSize + corpus.size;
        }, 0);
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath, ...cursor } });
    },
  },
};
