import { showModal } from "./modal";
import { localizeDateTime } from "./localize_datetime";

const csrfTokenSelector = "meta[name='csrf-token']";
const methodFieldSelector = "input[name='_method']";
const noteBodyFieldSelector = "textarea[name='note[body]']";
const noteSentimentRadioSelector = "input[name='note[sentiment]']:checked";
const notePreviewTriggerSelector = "[data-behavior=note-preview-trigger]";
const noteFavoriteToggleSelector = "[data-behavior=note-favorite-toggle]";

const formToJSON = form => {
  return {
    _csrf_token: document.querySelector(csrfTokenSelector).content,
    _method: document.querySelector(methodFieldSelector).value,
      note: {
      body: form.querySelector(noteBodyFieldSelector).value,
        sentiment: form.querySelector(noteSentimentRadioSelector).value
    }
  };
};

const saveNote = (url, data, { onSuccess, onFailure }) => {
  const xhr = new XMLHttpRequest();
  xhr.open('POST', url);
  xhr.setRequestHeader("Content-Type", "application/json");

  xhr.onload = () => {
    if (xhr.status === 200) {
      onSuccess();
    } else {
      onFailure();
    }
  };

  xhr.send(JSON.stringify(data));
};

const showNotePreviewModal = triggerElement => {
  const {
    id,
    submitted_at,
    sentiment,
    body,
    favorite,
    favorite_icon_path
  } = JSON.parse(triggerElement.getAttribute('data-note'));
  const localDateTime =
    localizeDateTime(submitted_at).format('MMM DD, YYYY - hh:mm:ss A');
  const favoriteToggletitle = favorite ? "Unstar this note" : "Star this note";

  showModal(`
    <div class="note-preview">
      <div class="meta">
        <span class="label">${localDateTime}</span>
        <img class="icon" src="/images/${sentiment}.svg" />
        <a
          href="javascript:void(0)"
          title="${favoriteToggletitle}"
          data-behavior="note-favorite-toggle"
          data-note-id="${id}"
          data-toggle-to="${!favorite}">
          <img class="icon star-icon" src="${favorite_icon_path}" />
        </a>
      </div>
      <p>${body}</p>
    </div>
  `);
};

const toggleFavorite = toggleElement => {
  const noteId = toggleElement.getAttribute('data-note-id');
  const toggleTo = toggleElement.getAttribute('data-toggle-to');
  const csrfToken = document.querySelector(csrfTokenSelector).content;

  const xhr = new XMLHttpRequest();
  xhr.open('PUT', `/notes/${noteId}/toggle_favorite`);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader('X-CSRF-Token', csrfToken);

  xhr.onload = () => {
    if (xhr.status === 200) {
      const { favorite } = JSON.parse(xhr.responseText);
      const favoriteIconPath = `/images/${favorite ? "star" : "unstar"}.svg`;
      const title = favorite ? "Unstar this note" : "Star this note";
      const newToggleTo = !favorite;
      const iconElement = toggleElement.querySelector("img");
      toggleElement.setAttribute("title", title);
      toggleElement.setAttribute("data-toggle-to", newToggleTo);
      iconElement && iconElement.setAttribute("src", favoriteIconPath);
    } else {
      const { error } = JSON.parse(xhr.responseText);
      alert(error || "An error occurred");
    }
  };

  xhr.send(JSON.stringify({favorite: toggleTo}));
};

document.addEventListener("DOMContentLoaded", () => {
  const form = document.querySelector(".note-form");
  if (!form) return;
  if (form.classList.contains("edit")) return;

  const url = form.getAttribute("action");

  form.addEventListener("submit", event => {
    event.preventDefault();
    const data = formToJSON(event.target);
    saveNote(
      url,
      data,
      { onSuccess: () => { form.reset() }, onFailure: () => {}}
    );
  });
});

document.addEventListener('click', ({ target}) => {
  if (target.closest(notePreviewTriggerSelector)) {
    showNotePreviewModal(target.closest(notePreviewTriggerSelector));
  }

  if (target.closest(noteFavoriteToggleSelector)) {
    toggleFavorite(target.closest(noteFavoriteToggleSelector));
  }
}, false);
