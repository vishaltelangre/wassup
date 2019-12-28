import { showModal, closeModal } from "./modal";
import { localizeDateTime } from "./localize_datetime";

const csrfTokenSelector = "meta[name='csrf-token']";
const noteFormSelector = "[data-behavior=note-form]";
const methodFieldSelector = "input[name='_method']";
const noteBodyFieldSelector = "textarea[name='note[body]']";
const noteSentimentRadioSelector = "input[name='note[sentiment]']:checked";
const notePreviewTriggerSelector = "[data-behavior=note-preview-trigger]";
const noteEditTriggerSelector = "[data-behavior=note-edit-trigger]";
const noteFavoriteToggleSelector = "[data-behavior=note-favorite-toggle]";

export const stringifyNote = note => JSON.stringify(note).replace("'", "&#39;");

const formToJSON = form => {
  const methodInput = document.querySelector(methodFieldSelector);

  return {
    _csrf_token: document.querySelector(csrfTokenSelector).content,
    _method: (methodInput && methodInput.value) || "post",
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
    <div class="note-preview" data-behavior="note-item" data-note-id="${id}">
      <div class="meta">
        <span class="label">${localDateTime}</span>
        <img class="icon" src="/images/${sentiment}.svg" data-behavior="sentiment-icon" />
        <a
          href="javascript:void(0)"
          title="${favoriteToggletitle}"
          data-behavior="note-favorite-toggle"
          data-note-id="${id}"
          data-toggle-to="${!favorite}">
          <img class="icon star-icon" src="${favorite_icon_path}" />
        </a>
      </div>
      <p data-behavior="note-body">${body}</p>
    </div>
  `);
};

const showNoteEditModal = triggerElement => {
  const {
    id,
    submitted_at,
    sentiment,
    body,
  } = JSON.parse(triggerElement.getAttribute('data-note'));
  const localDateTime =
    localizeDateTime(submitted_at).format('MMM DD, YYYY - hh:mm:ss A');
  const sentimentCheckedAttribute = radioSentiment =>
    sentiment === radioSentiment ? "checked='checked'" : "";

  showModal(`
    <div class="note-edit-modal">
      <h2>Editing Note</h2>
      <p class="muted">which was saved at <strong>${localDateTime}</strong></p>
      <form action="/notes/${id}" class="note-form" method="post" data-behavior="note-form" data-type="edit">
        <input name="_method" type="hidden" value="put">
        <textarea name="note[body]" placeholder="What's in your mind?">${body}</textarea>
        <span class="help-block"></span>
        <div class="row">
          <div class="column column-60">
            <div class="sentiment">
              <label class="control-label radio">
                <input name="note[sentiment]" type="radio" value="happy" ${sentimentCheckedAttribute('happy')}>
                <img src="/images/happy.svg">
              </label>
              <label class="control-label radio">
                <input name="note[sentiment]" type="radio" value="neutral" ${sentimentCheckedAttribute('neutral')}>
                <img src="/images/neutral.svg">
              </label>
              <label class="control-label radio">
                <input name="note[sentiment]" type="radio" value="sad" ${sentimentCheckedAttribute('sad')}>
                <img src="/images/sad.svg">
              </label>
            </div>
          </div>
          <div class="column column-40 actions">
            <div>
              <button class="button button-small button-outline" type="submit">Save</button>
            </div>
          </div>
        </div>
      </form>
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
    if (xhr.status !== 200) {
      const { error } = JSON.parse(xhr.responseText);
      alert(error || "An error occurred");
    }
  };

  xhr.send(JSON.stringify({favorite: toggleTo}));
};

document.addEventListener('submit', event => {
  if (event.target.closest(noteFormSelector)) {
    event.preventDefault();
    const form = event.target.closest(noteFormSelector);
    const url = form.getAttribute("action");
    const type = form.getAttribute("data-type");
    const data = formToJSON(form);
    const onSuccess = () => {
      if (type === "edit") {
        closeModal();
      } else {
        form.reset();
      }
    };
    saveNote(url, data, { onSuccess, onFailure: () => {} });
  }
}, false);

document.addEventListener('click', ({ target }) => {
  if (target.closest(notePreviewTriggerSelector)) {
    showNotePreviewModal(target.closest(notePreviewTriggerSelector));
  }

  if (target.closest(noteEditTriggerSelector)) {
    showNoteEditModal(target.closest(noteEditTriggerSelector));
  }

  if (target.closest(noteFavoriteToggleSelector)) {
    toggleFavorite(target.closest(noteFavoriteToggleSelector));
  }
}, false);
