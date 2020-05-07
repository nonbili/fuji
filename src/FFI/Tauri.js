const { readDir, readTextFile, writeFile } = require("tauri/api/fs");

const folder = "fuji";

const getPath = name => folder + "/" + name;

exports.readFiles_ = () =>
  readDir(folder).then(files =>
    Promise.all(files.map(file => readTextFile(file.path)))
  );

exports.readFile_ = fn => () => readTextFile(getPath(fn));

exports.writeFile_ = fn => contents => () =>
  writeFile({
    file: getPath(fn),
    contents
  });
