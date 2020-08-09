exports.getWordBeforeCursor_ = e => () => {
  const { value, selectionStart, selectionEnd } = e.currentTarget;
  const prevSpaceIndex = value.lastIndexOf(" ", selectionEnd - 1);
  const nextSpaceIndex = value.indexOf(" ", selectionEnd);

  if (
    selectionStart !== selectionEnd || // some text is selected
    (nextSpaceIndex !== -1 && nextSpaceIndex !== selectionEnd) // inside a word
  ) {
    return null;
  }

  const word = value.slice(prevSpaceIndex + 1, selectionEnd);
  return word;
};
