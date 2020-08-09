exports.getWordBeforeCursor_ = input => () => {
  const { value, selectionStart, selectionEnd } = input;
  const prevSpaceIndex = value.lastIndexOf(" ", selectionEnd - 1);
  const nextSpaceIndex = value.indexOf(" ", selectionEnd);

  if (
    selectionStart !== selectionEnd || // some text is selected
    (nextSpaceIndex !== -1 && nextSpaceIndex !== selectionEnd) || // inside a word
    (nextSpaceIndex === -1 && selectionEnd !== value.length) // inside the last word
  ) {
    return null;
  }

  const word = value.slice(prevSpaceIndex + 1, selectionEnd);
  return word;
};

exports.replaceWordBeforeCursor = word => input => () => {
  const { value, selectionStart, selectionEnd } = input;
  const prevSpaceIndex = value.lastIndexOf(" ", selectionEnd - 1);

  input.value =
    value.slice(0, prevSpaceIndex + 1) + word + value.slice(selectionEnd);

  return input.value;

  // TODO: Cursor will be moved to the end of input, should set cursor to the
  // end of word instead.
};
