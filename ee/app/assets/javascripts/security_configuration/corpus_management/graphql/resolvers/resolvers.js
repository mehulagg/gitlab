import produce from 'immer';
import { corpuses } from 'ee_jest/security_configuration/corpus_management/mock_data';
import getCorpusesQuery from '../queries/get_corpuses.query.graphql';

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
    /* eslint-disable no-unused-vars */
    uploadState(_, { projectPath }) {
      return {
        isUploading: false,
        progress: 0,
        __typename: 'UploadState',
      };
    },
  },
  Mutation: {
    addCorpus: (_, { name, projectPath }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        draftState.uploadState.isUploading = false;
        draftState.uploadState.progress = 0;

        draftState.mockedPackages.data = [
          ...draftState.mockedPackages.data,
          {
            name,
            lastUpdated: new Date().toString(),
            lastUsed: new Date().toString(),
            latestJobPath: '',
            target: '',
            downloadPath: 'farias-gl/go-fuzzing-example/-/jobs/959593462/artifacts/download',
            size: 4e8,
            __typename: 'CorpusData',
          },
        ];
        draftState.mockedPackages.totalSize += 4e8;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
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
    uploadCorpus: (_, { name, projectPath }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = true;
        // Simulate incrementing file upload progress
        uploadState.progress += 10;

        if (uploadState.progress >= 100) {
          uploadState.isUploading = false;
        }
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
      return data.uploadState.progress;
    },
    resetCorpus: (_, { name, projectPath }, { cache }) => {
      const sourceData = cache.readQuery({
        query: getCorpusesQuery,
        variables: { projectPath },
      });

      const data = produce(sourceData, (draftState) => {
        const { uploadState } = draftState;
        uploadState.isUploading = false;
        uploadState.progress = 0;
      });

      cache.writeQuery({ query: getCorpusesQuery, data, variables: { projectPath } });
    },
  },
};
