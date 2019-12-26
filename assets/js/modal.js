const modalSelector = "[data-behavior=modal]";
const modalContentSelector = "[data-behavior=modal-content]";
const modalCloseSelector = "[data-behavior=modal-close]";
const modalShowClassName = "show";

export const showModal = contents => {
  const modal = document.querySelector(modalSelector);

  modal.querySelector(modalContentSelector).innerHTML = contents;
  modal.classList.add(modalShowClassName);
}

document.addEventListener('DOMContentLoaded', () => {
  const modal = document.querySelector(modalSelector);
  const closeButton = document.querySelector(modalCloseSelector);

  closeButton.addEventListener('click', () => {
    modal.classList.remove(modalShowClassName);
  });
});
