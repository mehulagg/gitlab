import { insertTip, insertTips } from 'ee/security_configuration/api_fuzzing/utils';

const nonStringValues = [1, {}, null];

describe('insertTip', () => {
  describe.each(['snippet', 'tip', 'token'])('throws when %s is', (arg) => {
    const validValues = {
      snippet: 'snippet',
      tip: 'tip',
      token: 'token',
    };

    it.each(nonStringValues)('%s', (value) => {
      expect(() => {
        insertTip({ ...validValues, [arg]: value });
      }).toThrowError(`${arg} must be a string`);
    });
  });

  it('returns snippet as is if token can not be found', () => {
    const snippet = 'some code snippet';
    expect(
      insertTip({
        snippet,
        token: 'ghost',
        tip: 'a very helpful tip',
      }),
    ).toBe(snippet);
  });

  const tip = 'a very helpful tip';
  it.each`
    snippet                | token     | expected
    ${'some code snippet'} | ${'code'} | ${`some # ${tip}\ncode snippet`}
    ${'some code snippet'} | ${'some'} | ${`# ${tip}\nsome code snippet`}
    ${'some code snippet'} | ${'e'}    | ${`som# ${tip}\ne code snippet`}
  `('inserts the tip on the line before the first found token', ({ snippet, token, expected }) => {
    expect(
      insertTip({
        snippet,
        token,
        tip,
      }),
    ).toBe(expected);
  });
});

describe('insertTips', () => {
  const validTips = [
    {
      tip: 'Tip 1',
      token: 'stages:',
    },
    {
      tip: 'Tip 2',
      token: 'variables:',
    },
  ];

  it.each(nonStringValues)('throws if snippet is not a string', (snippet) => {
    expect(() => {
      insertTips(snippet, validTips);
    }).toThrowError('snippet must be a string');
  });

  describe.each(['tip', 'token'])('throws if %s', (prop) => {
    it.each(nonStringValues)('is %s', (value) => {
      expect(() => {
        insertTips('some code snippet', [
          {
            ...validTips[0],
            [prop]: value,
          },
        ]);
      }).toThrowError(`${prop} must be a string`);
    });
  });

  it('returns snippet as is if token can not be found', () => {
    const snippet = 'some code snippet';
    expect(insertTips(snippet, validTips)).toBe(snippet);
  });

  it('returns the snippet with properly inserted tips', () => {
    const snippet = `
---
stages:
- fuzz
include:
- template: template.gitlab-cy.yml
variables:
- FOO: bar`;
    const expected = `
---
# Tip 1
stages:
- fuzz
include:
- template: template.gitlab-cy.yml
# Tip 2
variables:
- FOO: bar`;
    expect(insertTips(snippet, validTips)).toBe(expected);
  });
});
