const { readDir, readTextFile } = require("tauri/api/fs");
const { readFile, writeFile } = require("../../src/js/tauri");

const folder = "fuji";

const getPath = name => folder + "/" + name;

exports.readFiles_ = () =>
  readDir(folder).then(files =>
    Promise.all(files.map(file => readTextFile(file.path)))
  );

exports.readFile_ = file => () => readFile(getPath(file));

exports.writeFile_ = file => contents => () =>
  writeFile(getPath(file), contents);
