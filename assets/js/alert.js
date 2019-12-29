const alertCloseSelector = "[data-behavior=alert-close]";

document.addEventListener('click', ({ target }) => {
  if (target.closest(alertCloseSelector)) {
    target.closest(alertCloseSelector).parentNode.remove();
  }
});
