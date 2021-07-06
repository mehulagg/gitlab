import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { uploadFile } from '~/content_editor/services/upload_file';
import httpStatus from '~/lib/utils/http_status';
import { loadMarkdownApiResult } from '../markdown_processing_examples';

describe('content_editor/services/upload_file', () => {
  const uploadsPath = '/uploads';
  const file = new File(['content'], 'file.txt');
  const successResponse = {
    link: {
      markdown: '[GitLab](https://gitlab.com)',
    },
  };
  const parseHTML = (html) => new DOMParser().parseFromString(html, 'text/html');
  let mock;
  let renderMarkdown;
  let renderedMarkdown;

  beforeEach(() => {
    const formData = new FormData();
    const htmlFixture = loadMarkdownApiResult('project_wiki_attachment_image').body;

    formData.append('file', file);

    renderedMarkdown = parseHTML(htmlFixture);

    mock = new MockAdapter(axios);
    mock.onPost(uploadsPath, formData).reply(httpStatus.OK, successResponse);
    renderMarkdown = jest.fn().mockResolvedValue(htmlFixture);
  });

  afterEach(() => {
    mock.restore();
  });

  it('returns src and canonicalSrc of uploaded file', async () => {
    const response = await uploadFile({ uploadsPath, renderMarkdown, file });

    expect(renderMarkdown).toHaveBeenCalledWith(successResponse.link.markdown);
    expect(response).toEqual({
      src: renderedMarkdown.querySelector('a').getAttribute('href'),
      canonicalSrc: renderedMarkdown.querySelector('a').dataset.canonicalSrc,
    });
  });
});
