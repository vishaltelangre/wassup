const toggleThemeSelector = "[data-behavior=toggle-theme]";
const lightModeKey = "light-mode";
const lightModeName = "Light Mode";
const darkModeModeName = "Dark Mode";

const toggleTheme = () => {
  const toggleElement = document.querySelector(toggleThemeSelector);

  if (localStorage.getItem(lightModeKey) === "true") {
    localStorage.removeItem(lightModeKey);
    document.body.classList.remove(lightModeKey);
    toggleElement.textContent = lightModeName;
  } else {
    localStorage.setItem(lightModeKey, "true");
    document.body.classList.add(lightModeKey);
    toggleElement.textContent = darkModeModeName;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const toggleElement = document.querySelector(toggleThemeSelector);

  try {
    if (localStorage.getItem(lightModeKey) === "true") {
      document.body.classList.add(lightModeKey);
      toggleElement.textContent = darkModeModeName;
    } else {
      toggleElement.textContent = lightModeName;
    }

    toggleElement.classList.remove("hide");

    document.addEventListener("click", ({ target }) => {
      const themeToggleTrigger = target && target.closest(toggleThemeSelector);
      if (themeToggleTrigger) {
        try { toggleTheme() } catch (e) {}
      }
    });
  } catch (e) {}
});
