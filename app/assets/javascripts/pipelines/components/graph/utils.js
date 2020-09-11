export const unwrapPipelineData = (mainPipelineId, data) => {
  console.log('in update', data);
  const {
    upstream: { nodes: upstream },
    downstream: { nodes: downstream },
    stages: { nodes: stages },
  } = data.project.pipeline;

  const unwrappedNestedGroups = stages
    .map((stage) => {
      const { groups: { nodes: groups }} = stage;
      return { ...stage, groups }
    });

  console.log('UNG:', unwrappedNestedGroups);

  const nodes = unwrappedNestedGroups.map(({ name, status, groups }) => {
    const groupsWithJobs = groups.map((group => {
        const jobs = group.jobs.nodes.map((job) => {
          const { needs } = job;
          return { ...job, needs: needs.nodes.map(need => need.name) };
        });

      return { ...group, jobs };
    }));

    return { name, status, groups: groupsWithJobs }
  });

  console.log('nodes', nodes);

  const addMulti = (pipeline) => {
    return { ...pipeline, multiproject: mainPipelineId !== pipeline.id }
  }

  return {
    stages: nodes,
    upstream: upstream.map(addMulti),
    downstream: downstream.map(addMulti),
  };

}
