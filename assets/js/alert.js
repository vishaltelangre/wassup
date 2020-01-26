const alertCloseSelector = "[data-behavior=alert-close]";

document.addEventListener('click', ({ target }) => {
  if (target.closest(alertCloseSelector)) {
    target.closest(alertCloseSelector).parentNode.remove();
  }
});

document.addEventListener('DOMContentLoaded', () => {
  const alertClose = document.querySelector(alertCloseSelector);
  if (alertClose) setTimeout(() => { alertClose.parentNode.remove() }, 5000);
});
