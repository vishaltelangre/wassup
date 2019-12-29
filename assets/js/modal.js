const modalSelector = "[data-behavior=modal]";
const modalContentSelector = "[data-behavior=modal-content]";
const modalCloseSelector = "[data-behavior=modal-close]";
const modalShowClassName = "show";
const noScrollClassName = "noscroll";

const showModal = contents => {
  const modal = document.querySelector(modalSelector);

  modal.querySelector(modalContentSelector).innerHTML = contents;
  modal.classList.add(modalShowClassName);
  document.body.classList.add(noScrollClassName);
}

const closeModal = () => {
  const modal = document.querySelector(modalSelector);
  modal.classList.remove(modalShowClassName);
  document.body.classList.remove(noScrollClassName);
};

document.addEventListener('DOMContentLoaded', () => {
  const closeButton = document.querySelector(modalCloseSelector);

  closeButton.addEventListener('click', closeModal);
});

export { showModal, closeModal };
