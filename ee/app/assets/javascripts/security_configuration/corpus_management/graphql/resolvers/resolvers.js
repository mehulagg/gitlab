import produce from 'immer';
import getCorpusesQuery from 'ee/security_configuration/corpus_management/graphql/queries/get_corpuses.query.graphql';
import { corpuses } from 'ee_jest/security_configuration/corpus_management/mock_data';

export default {
  Query: {
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
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
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

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
  },
};
