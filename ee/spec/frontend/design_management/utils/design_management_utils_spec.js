import underscore from 'underscore';
import {
  extractCurrentDiscussion,
  extractDiscussions,
  findVersionId,
  designUploadOptimisticResponse,
  getViewportCenter,
} from 'ee/design_management/utils/design_management_utils';

describe('extractCurrentDiscussion', () => {
  let discussions;

  beforeEach(() => {
    discussions = {
      edges: [
        { node: { id: 101, payload: 'w' } },
        { node: { id: 102, payload: 'x' } },
        { node: { id: 103, payload: 'y' } },
        { node: { id: 104, payload: 'z' } },
      ],
    };
  });

  it('finds the relevant discussion if it exists', () => {
    const id = 103;
    expect(extractCurrentDiscussion(discussions, id)).toEqual({
      node: { id, payload: 'y' },
    });
  });

  it('returns null if the relevant discussion does not exist', () => {
    expect(extractCurrentDiscussion(discussions, 0)).not.toBeDefined();
  });
});

describe('extractDiscussions', () => {
  let discussions;

  beforeEach(() => {
    discussions = {
      edges: [
        { node: { id: 1, notes: { edges: [{ node: 'a' }] } } },
        { node: { id: 2, notes: { edges: [{ node: 'b' }] } } },
        { node: { id: 3, notes: { edges: [{ node: 'c' }] } } },
        { node: { id: 4, notes: { edges: [{ node: 'd' }] } } },
      ],
    };
  });

  it('discards the edges.node artifacts of GraphQL', () => {
    expect(extractDiscussions(discussions)).toEqual([
      { id: 1, notes: ['a'] },
      { id: 2, notes: ['b'] },
      { id: 3, notes: ['c'] },
      { id: 4, notes: ['d'] },
    ]);
  });
});

describe('version parser', () => {
  it('correctly extracts version ID from a valid version string', () => {
    const testVersionId = '123';
    const testVersionString = `gid://gitlab/DesignManagement::Version/${testVersionId}`;

    expect(findVersionId(testVersionString)).toEqual(testVersionId);
  });

  it('fails to extract version ID from an invalid version string', () => {
    const testInvalidVersionString = `gid://gitlab/DesignManagement::Version`;

    expect(findVersionId(testInvalidVersionString)).toBeUndefined();
  });
});

describe('optimistic responses', () => {
  it('correctly generated for design upload', () => {
    jest.spyOn(underscore, 'uniqueId').mockImplementation(() => 1);
    const expectedResponse = {
      __typename: 'Mutation',
      designManagementUpload: {
        __typename: 'DesignManagementUploadPayload',
        designs: [
          {
            __typename: 'Design',
            id: -1,
            image: '',
            filename: 'test',
            fullPath: '',
            notesCount: 0,
            event: 'NONE',
            diffRefs: { __typename: 'DiffRefs', baseSha: '', startSha: '', headSha: '' },
            discussions: { __typename: 'DesignDiscussion', edges: [] },
            versions: {
              __typename: 'DesignVersionConnection',
              edges: {
                __typename: 'DesignVersionEdge',
                node: { __typename: 'DesignVersion', id: -1, sha: -1 },
              },
            },
          },
        ],
      },
    };
    expect(designUploadOptimisticResponse([{ name: 'test' }])).toEqual(expectedResponse);
  });
});

describe('getViewportCenter', () => {
  /**
   * Mock an element
   * @param {Object} viewportDimensions {width, height}
   * @param {Object} childDimensions {width, height}
   * @param {Float} scrollTopPerc 0 < x < 1
   * @param {Float} scrollLeftPerc  0 < x < 1
   */
  const mockElemFactory = (viewportDimensions, childDimensions, scrollTopPerc, scrollLeftPerc) => ({
    scrollWidth: childDimensions.width,
    scrollHeight: childDimensions.height,
    offsetWidth: viewportDimensions.width,
    offsetHeight: viewportDimensions.height,
    scrollLeft: (childDimensions.width - viewportDimensions.width) * scrollLeftPerc,
    scrollTop: (childDimensions.height - viewportDimensions.height) * scrollTopPerc,
  });

  it('calculate center correctly with no scroll', () => {
    const mockElem = mockElemFactory({ width: 10, height: 10 }, { width: 20, height: 20 }, 0, 0);

    expect(getViewportCenter(mockElem)).toEqual({
      x: 5,
      y: 5,
      xRatio: 0.25,
      yRatio: 0.25,
    });
  });

  it('calculate center correctly with some scroll', () => {
    const mockElem = mockElemFactory(
      { width: 10, height: 10 },
      { width: 20, height: 20 },
      0.5,
      0.5,
    );

    expect(getViewportCenter(mockElem)).toEqual({
      x: 10,
      y: 10,
      xRatio: 0.5,
      yRatio: 0.5,
    });
  });

  it('Returns default case if no overflow (scrollWidth==offsetWidth, etc.)', () => {
    const mockElem = mockElemFactory(
      { width: 20, height: 20 },
      { width: 20, height: 20 },
      0.5,
      0.5,
    );

    expect(getViewportCenter(mockElem)).toEqual({
      x: 10,
      y: 10,
      xRatio: 0.5,
      yRatio: 0.5,
    });
  });
});
