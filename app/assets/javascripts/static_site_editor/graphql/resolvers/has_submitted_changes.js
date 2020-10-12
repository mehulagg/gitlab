import { produce } from 'immer';
import query from '../queries/app_data.query.graphql';

const hasSubmittedChangesResolver = (_, { input: { hasSubmittedChanges } }, { cache }) => {
  const oldData = cache.readQuery({ query });

  const data = produce(oldData, draftState => {
    // punctually modifying draftState as per immer docs upsets our linters
    return {
      ...draftState,
      appData: {
        ...draftState.appData,
        __typename: 'AppData',
        hasSubmittedChanges,
      },
    };
  });

  cache.writeQuery({
    query,
    data,
  });
};

export default hasSubmittedChangesResolver;
