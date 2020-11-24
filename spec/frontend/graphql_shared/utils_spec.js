import {
  getIdFromGraphQLId,
  convertToGraphQLId,
  convertToGraphQLIds,
} from '~/graphql_shared/utils';

describe('getIdFromGraphQLId', () => {
  [
    {
      input: '',
      output: null,
    },
    {
      input: null,
      output: null,
    },
    {
      input: 2,
      output: 2,
    },
    {
      input: 'gid://',
      output: null,
    },
    {
      input: 'gid://gitlab/',
      output: null,
    },
    {
      input: 'gid://gitlab/Environments',
      output: null,
    },
    {
      input: 'gid://gitlab/Environments/',
      output: null,
    },
    {
      input: 'gid://gitlab/Environments/123',
      output: 123,
    },
    {
      input: 'gid://gitlab/DesignManagement::Version/2',
      output: 2,
    },
  ].forEach(({ input, output }) => {
    it(`getIdFromGraphQLId returns ${output} when passed ${input}`, () => {
      expect(getIdFromGraphQLId(input)).toBe(output);
    });
  });
});

describe('convertToGraphQLId', () => {
  it.each`
    type       | id      | result
    ${'Group'} | ${12}   | ${`gid://gitlab/Group/12`}
    ${'Group'} | ${null} | ${null}
    ${null}    | ${12}   | ${null}
  `('combines $type and $id into $result', ({ type, id, result }) =>
    expect(convertToGraphQLId(type, id)).toBe(result),
  );
});

describe('convertToGraphQLIds', () => {
  it.each`
    type       | ids       | result
    ${'Group'} | ${[1, 2]} | ${[`gid://gitlab/Group/1`, `gid://gitlab/Group/2`]}
    ${'Group'} | ${null}   | ${null}
    ${null}    | ${12}     | ${null}
  `('combines $type and $id into $result', ({ type, ids, result }) =>
    expect(convertToGraphQLIds(type, ids)).toStrictEqual(result),
  );
});
