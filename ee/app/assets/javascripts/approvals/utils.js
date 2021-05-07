import { flatten } from 'lodash';

export const joinRuleResponses = (responsesArray) =>
  Object.assign({}, ...responsesArray, {
    rules: flatten(responsesArray.map(({ rules }) => rules)),
  });
