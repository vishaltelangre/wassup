import { showModal } from "./modal";
import { localizeDateTime } from "./localize_datetime";

const formToJSON = form => {
  return {
    _csrf_token: form.querySelector("input[name='_csrf_token']").value,
      note: {
      body: form.querySelector("textarea[name='note[body]']").value,
        sentiment: form.querySelector("input[name='note[sentiment]']:checked").value
    }
  };
};

const submitForm = (url, data, { onSuccess, onFailure }) => {
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

document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector(".note-form");
  if (!form) return;

  const url = form.getAttribute("action");

  form.addEventListener('submit', event => {
    event.preventDefault();
    const data = formToJSON(event.target);
    submitForm(
      url,
      data,
      { onSuccess: () => { form.reset() }, onFailure: () => {}}
    );
  });
});

document.addEventListener('click', ({target}) => {
  if (target.getAttribute('data-behavior') === "note-preview-trigger") {
    const { submitted_at, sentiment, body } = JSON.parse(target.getAttribute('data-note'));
    const localDateTime = localizeDateTime(submitted_at).format('MMM DD, YYYY - hh:mm:ss A');

    showModal(`
      <div class="note-preview">
        <div class="meta">
          <span class="submitted">${localDateTime}</span>
          <img class="emoji-icon" src="/images/${sentiment}.svg" />
        </div>
        <p>${body}</p>
      </div>
    `);
  }
}, false)
