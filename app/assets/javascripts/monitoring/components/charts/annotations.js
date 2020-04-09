import { graphTypes, symbolSizes, colorValues } from '../../constants';

/**
 * Annotations and deployments are decoration layers on
 * top of the actual chart data. We use a scatter plot to
 * display this information. Each chart has its coordinate
 * system based on data and irresptive of the data, these
 * decorations have to be placed in specific locations.
 * For this reason, annotations have their own coordinate system,
 *
 * As of %12.9, only deployment icons, a type of annotations, need
 * to be displayed on the chart.
 *
 * After https://gitlab.com/gitlab-org/gitlab/-/issues/211418,
 * annotations and deployments will co-exist in the same
 * series as they logically belong together. Annotations will be
 * passed as markLine objects.
 */

/**
 * Deployment icons, a type of annotation, are displayed
 * along the [min, max] range at height `pos`.
 */
const annotationsYAxisCoords = {
  min: 0,
  pos: 3, // 3% height of chart's grid
  max: 100,
};

/**
 * Annotation y axis min & max allows the deployment
 * icons to position correctly in the chart
 */
export const annotationsYAxis = {
  show: false,
  min: annotationsYAxisCoords.min,
  max: annotationsYAxisCoords.max,
  axisLabel: {
    // formatter fn required to trigger tooltip re-positioning
    formatter: () => {},
  },
};

/**
 * Fetched list of annotations are parsed into a
 * format the eCharts accepts to draw markLines
 *
 * If Annotation is a single line, the `from` property
 * has a value and the `to` is null. Because annotations
 * only supports lines the from value does not exist yet.
 *
 *
 * @param {Object} annotation object
 * @returns {Object} markLine object
 */
export const parseAnnotations = ({
  from: annotationFrom = '',
  color = colorValues.primaryColor,
}) => ({
  xAxis: annotationFrom,
  lineStyle: {
    color,
  },
});

/**
 * This method currently generates deployments and annotations
 * but are not used in the chart. The method calling
 * generateAnnotationsSeries will not pass annotations until
 * https://gitlab.com/gitlab-org/gitlab/-/issues/211330 is
 * implemented.
 *
 * This method is extracted out of the charts so that
 * annotation lines can be easily supported in
 * the future.
 *
 * In order to make hover work, hidden annotation data points
 * are created along with the markLines. These data points have
 * the necessart metadata that is used to display in the tooltip.
 *
 * @param {Array} deployments deployments data
 * @returns {Object} annotation series object
 */
export const generateAnnotationsSeries = ({ deployments = [], annotations = [] } = {}) => {
  // deployment data points
  const deploymentsData = deployments.map(deployment => {
    return {
      name: 'deployments',
      value: [deployment.createdAt, annotationsYAxisCoords.pos],
      symbol: deployment.icon,
      symbolSize: symbolSizes.default,
      itemStyle: {
        color: deployment.color,
      },
    };
  });

  // annotation data points
  const annotationsData = annotations.map(annotation => {
    return {
      name: 'annotations',
      value: [annotation.from, annotationsYAxisCoords.pos],
      symbol: 'none',
      description: annotation.description,
    };
  });

  // annotation markLine option
  const markLine = {
    symbol: 'none',
    silent: true,
    data: annotations.map(parseAnnotations),
  };

  return {
    type: graphTypes.annotationsData,
    yAxisIndex: 1, // annotationsYAxis index
    data: [...deploymentsData, ...annotationsData],
    markLine,
  };
};
