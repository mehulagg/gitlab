import * as d3 from 'd3';

/**
 * This function is chained after `createNodeDict`.
 * The resulting data (which contains nodes and links)
 * is passed down as the first argument and we use
 * only the links. For each link, we find the nodes
 * in the graph, calculate their coordinates and
 * trace the lines that represent the needs of each
 * job.
 * @param {Object} nodeDict - Resulting object of `createNodeDict` with nodes and links
 * @param {ref} svg - reference to the svg we draw in
 * @returns {undefined}
 */

export const drawGraphLinks = ({ links }, svg) => {
  const svgEl = document.querySelector('#pipeline-graph-container');

  return links.forEach(link => {
    const path = d3.path();

    const sourceEl = document.querySelector(`[data-testid=${link.source}]`);
    const targetEl = document.querySelector(`[data-testid=${link.target}]`);

    const sourceCoordinates = sourceEl.getBoundingClientRect();
    const targetCoordinates = targetEl.getBoundingClientRect();
    const svgCoordinates = svgEl.getBoundingClientRect();

    const paddingLeft = Number(
      window
        .getComputedStyle(svgEl, null)
        .getPropertyValue('padding-left')
        .replace('px', ''),
    );
    const paddingTop = Number(
      window
        .getComputedStyle(svgEl, null)
        .getPropertyValue('padding-top')
        .replace('px', ''),
    );

    // Because we add the svg dynamically and calculate the coordinates
    // with plain JS and not D3, we need to account for the fact that
    // the coordinates we are getting are absolutes, but we want to draw
    // relative to the svg container, which starts at `svgCoordinates`
    // so we substract these from the total. We also need to remove the padding
    // from the total to make sure it's aligned properly. We then make the line
    // positioned in the center of the job node by adding half the height
    // of the job pill.
    const sourceX = sourceCoordinates.right - svgCoordinates.x - paddingLeft;
    const sourceY =
      sourceCoordinates.top - svgCoordinates.y - paddingTop + sourceCoordinates.height / 2;
    const targetX = targetCoordinates.x - svgCoordinates.x - paddingLeft;
    const targetY =
      targetCoordinates.y - svgCoordinates.y - paddingTop + sourceCoordinates.height / 2;

    path.moveTo(sourceX, sourceY);
    // Add bezier curve. The first 4 coordinates of 2 control
    // points to create the curve, and the last one is the end point.
    // we want our control points to be in the middle of the line
    const controlPointX = sourceX + (targetX - sourceX) / 2;

    path.bezierCurveTo(controlPointX, sourceY, controlPointX, targetY, targetX, targetY);

    svg
      .append('path')
      .attr('d', path.toString())
      .attr('stroke', 'black')
      .attr('fill', 'transparent')
      .attr('stroke-width', 1);
  });
};
