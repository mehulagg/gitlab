import { helpPagePath } from '~/helpers/help_page_helper';

describe('help page helper', () => {
  it.each`
    path               | anchor       | expected
    ${'/help/me'}      | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me/'}      | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'/help/me/'}     | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me.md'}    | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me.html'}  | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me.md/'}   | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me.html/'} | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me'}       | ${'h4sh'}    | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me'}       | ${'#h4sh'}   | ${'https://docs.gitlab.com/ee/user/help/me#h4sh'}
    ${'help/me'}       | ${undefined} | ${'https://docs.gitlab.com/ee/user/help/me'}
  `(
    'generates correct URL when path is `$path` and anchor is `$anchor`',
    ({ anchor, path, expected }) => {
      expect(helpPagePath(path, { anchor })).toBe(expected);
    },
  );
});
