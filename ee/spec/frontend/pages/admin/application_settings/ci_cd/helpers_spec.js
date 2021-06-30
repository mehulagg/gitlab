import { filterGitlabCiYmls } from 'ee/pages/admin/application_settings/ci_cd/helpers';

describe('CI/CD helpers', () => {
  const Yml = (name) => ({ name, id: name });
  it.each`
    gitlabCiYmls                                                   | searchTerm | result
    ${{ CatA: [Yml('test'), Yml('node')], CatB: [Yml('test')] }}   | ${'t'}     | ${{ CatA: [Yml('test')], CatB: [Yml('test')] }}
    ${{ CatA: [Yml('test'), Yml('tether')], CatB: [Yml('test')] }} | ${'tet'}   | ${{ CatA: [Yml('tether')] }}
    ${{ CatA: [Yml('test'), Yml('node')], CatB: [Yml('test')] }}   | ${'n'}     | ${{ CatA: [Yml('node')] }}
    ${{ CatA: [Yml('test'), Yml('node')], CatB: [Yml('test')] }}   | ${'asd'}   | ${{}}
  `(
    'returns filtered list with correct categories when search term is $searchTerm',
    ({ gitlabCiYmls, searchTerm, result }) => {
      expect(filterGitlabCiYmls(gitlabCiYmls, searchTerm)).toEqual(result);
    },
  );
});
