const { readFile, writeFile, tauriOn } = require("../../src/js/tauri");

const folder = tauriOn ? localStorage.getItem("fuji") : "fuji";

const getPath = name => folder + "/" + name;

exports.getDataDir_ = () => folder;

exports.readFile_ = file => () => readFile(getPath(file));

exports.writeFile_ = file => contents => () =>
  writeFile(getPath(file), contents);
