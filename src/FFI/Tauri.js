const { readDir, readTextFile, writeFile } = require("tauri/api/fs");

const folder = "fuji";

const getPath = name => folder + "/" + name;

exports.readFiles_ = () =>
  readDir(folder).then(files =>
    Promise.all(files.map(file => readTextFile(file.path)))
  );

exports.writeFile_ = ts => contents => () =>
  writeFile({
    file: getPath(ts),
    contents
  });
