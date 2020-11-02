import downloader from '~/lib/utils/downloader';

describe('Downloader', () => {
  let a;

  beforeEach(() => {
    a = { click: jest.fn() };
    jest.spyOn(document, 'createElement').mockImplementation(() => a);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('when inline file content is provided', () => {
    const fileData = 'inline content';
    const fileName = 'test.csv';
    const fileType = 'text/csv';

    it('uses the data urls to download the file with the default fileType', () => {
      downloader({ fileName, fileData });
      expect(document.createElement).toHaveBeenCalledWith('a');
      expect(a.download).toBe(fileName);
      expect(a.href).toBe(`data:text/plain;base64,${fileData}`);
      expect(a.click).toHaveBeenCalledTimes(1);
    });

    it('uses the data urls to download the file with the given fileType', () => {
      downloader({ fileName, fileData, fileType });
      expect(document.createElement).toHaveBeenCalledWith('a');
      expect(a.download).toBe(fileName);
      expect(a.href).toBe(`data:${fileType};base64,${fileData}`);
      expect(a.click).toHaveBeenCalledTimes(1);
    });
  });

  describe('when an endpoint is provided', () => {
    const url = 'https://gitlab.com/test.csv';
    const fileName = 'test.csv';

    it('uses the endpoint to download the file', () => {
      downloader({ fileName, url });
      expect(document.createElement).toHaveBeenCalledWith('a');
      expect(a.download).toBe(fileName);
      expect(a.href).toBe(url);
      expect(a.click).toHaveBeenCalledTimes(1);
    });
  });
});
