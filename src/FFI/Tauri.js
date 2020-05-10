const TauriDialog = require("tauri/api/dialog");
const TauriFS = require("tauri/api/fs");

const { readFile, writeFile, tauriOn } = require("../../src/js/tauri");

let dataDir = tauriOn ? localStorage.getItem("fuji") : "fuji";

const getFilePath = name => dataDir + "/" + name;

exports.getDataDir_ = () => dataDir;

exports.setDataDir = dir => () => {
  dataDir = dir;
  TauriFS.createDir(getFilePath("notes"));
  localStorage.setItem("fuji", dir);
};

exports.readFile_ = file => () => readFile(getFilePath(file));

exports.writeFile_ = file => contents => () =>
  writeFile(getFilePath(file), contents);

exports.openDialog_ = () =>
  TauriDialog.open({
    directory: true
  });
