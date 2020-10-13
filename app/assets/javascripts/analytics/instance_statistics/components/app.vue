<script>
import { getDateInPast } from '~/lib/utils/datetime_utility';
import InstanceCounts from './instance_counts.vue';
import UsersChart from './users_chart.vue';
import ProjectsAndGroupsChart from './projects_and_groups_chart.vue';

const TOTAL_DATAPOINTS_TO_FETCH = 365;
const TODAY = new Date();
const START_DATE = getDateInPast(TODAY, TOTAL_DATAPOINTS_TO_FETCH);

export default {
  name: 'InstanceStatisticsApp',
  components: {
    InstanceCounts,
    UsersChart,
    ProjectsAndGroupsChart,
  },
  TOTAL_DATAPOINTS_TO_FETCH,
  TODAY,
  START_DATE,
};
</script>

<template>
  <div>
    <instance-counts />
    <users-chart
      :start-date="$options.START_DATE"
      :end-date="$options.TODAY"
      :total-data-points="$options.TOTAL_DATAPOINTS_TO_FETCH"
    />
    <projects-and-groups-chart
      :start-date="$options.START_DATE"
      :end-date="$options.TODAY"
      :total-data-points="$options.TOTAL_DATAPOINTS_TO_FETCH"
    />
  </div>
</template>
