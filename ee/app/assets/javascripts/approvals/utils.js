import { flatten } from 'lodash';

export const joinRuleResponses = (responses) =>
  Object.assign({}, ...responses, {
    rules: flatten(responses.map(({ rules }) => rules)),
  });
