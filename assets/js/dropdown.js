const triggerClassName = "dropdown-trigger";
const contentClassName = "dropdown-content";
const showClassName = "show";

document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener("click", ({target}) => {
    // When user clicks on a dropdown trigger,
    // toggle show/hide the resembled dropdown contents
    const closestTriggerTarget = target && target.closest(`.${triggerClassName}`);
    if (closestTriggerTarget) {
      const content = closestTriggerTarget.parentNode.querySelector(`.${contentClassName}`);
      content.classList.toggle("show");
    // Close the dropdown if user clicks outside of the dropdown
    } else {
      const dropdowns = document.getElementsByClassName(contentClassName);
      for (let dropdown of dropdowns) {
        if (dropdown.classList.contains(showClassName)) {
          dropdown.classList.remove(showClassName);
        }
      }
    }
  }, false);
});
