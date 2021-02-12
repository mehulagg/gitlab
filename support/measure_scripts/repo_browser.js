const basePath = "http://host.docker.internal:3000";
const baseRepo = "/flightjs/Flight";

module.exports = async function (context, commands) {
  // we fetch the selenium webdriver from context
  const webdriver = context.selenium.webdriver;
  const driver = context.selenium.driver;

  // Preloading and pre-setting the performance bar cookie
  await commands.navigate(basePath + "/users/sign_in");

  driver.manage().addCookie({ name: "perf_bar_enabled", value: "false" });

  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );

  const projectSelector = `a[href="${baseRepo}"]`;

  await commands.navigate(basePath + "/explore");
  await commands.wait.bySelector(projectSelector);

  // Lets start measuring
  await commands.measure.start("RepoJourney");

  await commands.click.bySelector(projectSelector);

  const directory1Selector = 'a[href="/flightjs/Flight/-/tree/master/test"]';

  await commands.wait.bySelector(directory1Selector, 15000);
  await commands.click.bySelector(directory1Selector);

  console.log("Clicked in directory 1");

  const directory2Selector =
    'a[href="/flightjs/Flight/-/tree/master/test/spec"]';

  await commands.wait.bySelector(directory2Selector, 15000);
  await commands.click.bySelector(directory2Selector);

  console.log("Clicked in directory 2");

  const fileSelector =
    'a[href="/flightjs/Flight/-/blob/master/test/spec/attribute_spec.js"]';

  await commands.wait.bySelector(fileSelector, 15000);
  await commands.click.bySelector(fileSelector);

  console.log("Clicked in file");

  // Lets wait for text in the actual file
  await commands.wait.bySelector("#LC34");

  return commands.measure.stop();
};
