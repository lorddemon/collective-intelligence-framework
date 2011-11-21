cifsearch.onFirefoxLoad = function(event) {
  document.getElementById("contentAreaContextMenu")
          .addEventListener("popupshowing", function (e){ cifsearch.showFirefoxContextMenu(e); }, false);
};

cifsearch.showFirefoxContextMenu = function(event) {
  // show or hide the menuitem based on what the context menu is on
  document.getElementById("context-cifsearch").hidden = gContextMenu.onImage;
};

window.addEventListener("load", cifsearch.onFirefoxLoad, false);
