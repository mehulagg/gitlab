import * as roadmapItemUtils from 'ee/roadmap/utils/roadmap_item_utils';

import { parsePikadayDate } from '~/lib/utils/datetime_utility';

import { rawEpics, mockGroupMilestonesQueryResponse } from '../mock_data';

describe('processRoadmapItemDates', () => {
  const timeframeStartDate = new Date(2017, 0, 1);
  const timeframeEndDate = new Date(2017, 11, 31);

  it('Should set `startDateOutOfRange`/`endDateOutOfRange` as true and `startDate` and `endDate` to dates of timeframe range when epic dates are outside timeframe range', () => {
    const mockEpic = {
      originalStartDate: new Date(2016, 11, 15),
      originalEndDate: new Date(2018, 0, 1),
    };

    const updatedEpic = roadmapItemUtils.processRoadmapItemDates(
      mockEpic,
      timeframeStartDate,
      timeframeEndDate,
    );

    expect(updatedEpic.startDateOutOfRange).toBe(true);
    expect(updatedEpic.endDateOutOfRange).toBe(true);
    expect(updatedEpic.startDate.getTime()).toBe(timeframeStartDate.getTime());
    expect(updatedEpic.endDate.getTime()).toBe(timeframeEndDate.getTime());
  });

  it('Should set `startDateOutOfRange`/`endDateOutOfRange` as false and `startDate` and `endDate` to actual epic dates when they are within timeframe range', () => {
    const mockEpic = {
      originalStartDate: new Date(2017, 2, 10),
      originalEndDate: new Date(2017, 6, 22),
    };

    const updatedEpic = roadmapItemUtils.processRoadmapItemDates(
      mockEpic,
      timeframeStartDate,
      timeframeEndDate,
    );

    expect(updatedEpic.startDateOutOfRange).toBe(false);
    expect(updatedEpic.endDateOutOfRange).toBe(false);
    expect(updatedEpic.startDate.getTime()).toBe(mockEpic.originalStartDate.getTime());
    expect(updatedEpic.endDate.getTime()).toBe(mockEpic.originalEndDate.getTime());
  });

  it('Should set `startDate` and `endDate` to timeframe start and end dates when epic dates are undefined', () => {
    const mockEpic = {
      startDateUndefined: true,
      endDateUndefined: true,
    };

    const updatedEpic = roadmapItemUtils.processRoadmapItemDates(
      mockEpic,
      timeframeStartDate,
      timeframeEndDate,
    );

    expect(updatedEpic.startDate.getTime()).toBe(timeframeStartDate.getTime());
    expect(updatedEpic.endDate.getTime()).toBe(timeframeEndDate.getTime());
  });
});

describe('formatRoadmapItemDetails', () => {
  const timeframeStartDate = new Date(2017, 0, 1);
  const timeframeEndDate = new Date(2017, 11, 31);
  const rawEpic = rawEpics[0];

  it('Should return formatted Epic object from raw Epic object', () => {
    const epic = roadmapItemUtils.formatRoadmapItemDetails(
      rawEpic,
      timeframeStartDate,
      timeframeEndDate,
    );

    expect(epic.id).toBe(rawEpic.id);
    expect(epic.name).toBe(rawEpic.name);
    expect(epic.groupId).toBe(rawEpic.group_id);
    expect(epic.groupName).toBe(rawEpic.group_name);
  });

  it('Should return formatted Epic object with `startDate`/`endDate` and `originalStartDate`/originalEndDate` initialized when dates are present', () => {
    const mockRawEpic = {
      start_date: '2017-2-15',
      end_date: '2017-7-22',
    };

    const epic = roadmapItemUtils.formatRoadmapItemDetails(
      mockRawEpic,
      timeframeStartDate,
      timeframeEndDate,
    );

    const startDate = parsePikadayDate(mockRawEpic.start_date);
    const endDate = parsePikadayDate(mockRawEpic.end_date);

    expect(epic.startDate.getTime()).toBe(startDate.getTime());
    expect(epic.originalStartDate.getTime()).toBe(startDate.getTime());
    expect(epic.endDate.getTime()).toBe(endDate.getTime());
    expect(epic.originalEndDate.getTime()).toBe(endDate.getTime());
  });

  it('Should return formatted Epic object with `startDateUndefined`/startDateUndefined` set to true when dates are null/undefined', () => {
    const epic = roadmapItemUtils.formatRoadmapItemDetails(
      {},
      timeframeStartDate,
      timeframeEndDate,
    );

    expect(epic.originalStartDate).toBeUndefined();
    expect(epic.originalEndDate).toBeUndefined();
    expect(epic.startDateUndefined).toBe(true);
    expect(epic.endDateUndefined).toBe(true);
  });
});

describe('extractGroupMilestones', () => {
  it('returns array of epics with `edges->nodes` nesting removed', () => {
    const { edges } = mockGroupMilestonesQueryResponse.data.group.milestones;
    const extractedMilestones = roadmapItemUtils.extractGroupMilestones(edges);

    expect(extractedMilestones).toHaveLength(edges.length);
    expect(extractedMilestones[0]).toEqual(
      expect.objectContaining({
        ...edges[0].node,
      }),
    );
  });
});
