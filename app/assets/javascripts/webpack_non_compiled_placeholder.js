document.addEventListener('DOMContentLoaded', () => {
  const div = document.createElement('div');
  div.innerHTML = `
    <div
      style="width: 100vw;position:absolute;top:0;left:0;z-index:100000;height:100vh;background:rgba(0,0,0,0.7);font-size: 25px;font-family: monospace;color: white;padding: 2.5em;text-align:center"
    >
      🧙 Webpack is doing its magic 🧙<br/>
      Please bear with us for a second and the page will reload.
    </div>`;

  document.body.append(div);
});
