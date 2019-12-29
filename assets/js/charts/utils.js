import { stringifyNote } from "./../note";

const defaultTruncateMaxLength = 120;

const truncateNoteBodyForChartTooltip = (note, maxLength = defaultTruncateMaxLength) => {
  const { body } = note;
  const exceedingMaxBodyLength = body.length > maxLength;
  const modalTriggerAttributes = `
    data-note='${stringifyNote(note)}'
    data-behavior="note-preview-trigger"
  `;
  const elipsis = exceedingMaxBodyLength
    ? ` <a href="javascript:void(0)" ${modalTriggerAttributes}>…</a>`
    : "";
  const truncatedBody = body.substring(0, maxLength) + elipsis;

  return `<p ${modalTriggerAttributes}>${truncatedBody}</p>`;
};

export { truncateNoteBodyForChartTooltip };
