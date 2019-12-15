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
