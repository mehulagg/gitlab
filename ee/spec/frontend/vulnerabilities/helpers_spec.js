import { getFormattedIssue, getAddRelatedIssueRequestParams } from 'ee/vulnerabilities/helpers';

describe('Vulnerabilities helpers', () => {
  describe('getFormattedIssue', () => {
    it.each([{ iid: 135, web_url: 'some/url' }, { iid: undefined, web_url: undefined }])(
      'returns formatted issue with expected properties for issue %s',
      issue => {
        const formattedIssue = getFormattedIssue(issue);

        expect(formattedIssue).toMatchObject({
          ...issue,
          reference: `#${issue.iid}`,
          path: issue.web_url,
        });
      },
    );
  });

  describe('getAddRelatedIssueRequestParams', () => {
    const defaultPath = 'default/path';

    it.each`
      reference                                          | target_issue_iid                              | target_project_id
      ${'135'}                                           | ${'135'}                                      | ${defaultPath}
      ${'#246'}                                          | ${'246'}                                      | ${defaultPath}
      ${'https://localhost:3000/root/test/-/issues/357'} | ${'357'}                                      | ${'root/test'}
      ${'/root/test/-/issues/357'}                       | ${'/root/test/-/issues/357'}                  | ${defaultPath}
      ${'invalidReference'}                              | ${'invalidReference'}                         | ${defaultPath}
      ${'/?something/@#$%/@#$%/-/issues/1234'}           | ${'/?something/@#$%/@#$%/-/issues/1234'}      | ${defaultPath}
      ${'http://something/@#$%/@#$%/-/issues/1234'}      | ${'http://something/@#$%/@#$%/-/issues/1234'} | ${defaultPath}
    `(
      'gets correct request params for the reference "$reference"',
      async ({ reference, target_issue_iid, target_project_id }) => {
        const params = getAddRelatedIssueRequestParams(reference, defaultPath);

        expect(params).toMatchObject({ target_issue_iid, target_project_id });
      },
    );
  });
});
