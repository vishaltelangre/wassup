const triggerSelector = "[data-behavior=dropdown-trigger]";
const contentSelector = "[data-behavior=dropdown-content]";
const showClassName = "show";

document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener("click", ({target}) => {
    // Close all expanded dropdowns
    const dropdowns = document.querySelectorAll(contentSelector);
    for (let dropdown of dropdowns) {
      const containsDateRangePicker = dropdown.closest('[data-behavior=daterange-picker]');
      if (dropdown.classList.contains(showClassName) && !containsDateRangePicker) {
        dropdown.classList.remove(showClassName);
      }
    }
    // When user clicks on a dropdown trigger,
    // toggle show/hide the resembled dropdown contents
    const closestTriggerTarget = target && target.closest(triggerSelector);
    if (closestTriggerTarget) {
      const content = closestTriggerTarget.parentNode.querySelector(contentSelector);
      content.classList.toggle(showClassName);
    }
  }, false);
});
