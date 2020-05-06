const { writeFile } = require("tauri/api/fs");

exports.writeFile_ = ts => contents => () => {
  writeFile({
    file: ts.toString(),
    contents
  });
};
