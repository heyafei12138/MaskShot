const switches = document.querySelectorAll(".switch");
const panels = document.querySelectorAll("[data-screen-panel]");

function activateScreen(name) {
  switches.forEach((item) => {
    item.classList.toggle("is-active", item.dataset.screen === name);
  });

  panels.forEach((panel) => {
    panel.classList.toggle("is-active", panel.dataset.screenPanel === name);
  });
}

switches.forEach((item) => {
  item.addEventListener("click", () => {
    activateScreen(item.dataset.screen);
    history.replaceState(null, "", `#${item.dataset.screen}`);
  });
});

const initialScreen = new URLSearchParams(location.search).get("screen") || location.hash.replace("#", "");
if (initialScreen) {
  activateScreen(initialScreen);
}
