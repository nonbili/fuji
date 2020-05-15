const TauriDialog = require("tauri/api/dialog");
const TauriFS = require("tauri/api/fs");

const {
  readFile,
  writeFile,
  removeFile,
  readConfig,
  writeConfig,
  tauriOn
} = require("../../src/js/tauri");

let dataDir;

const getFilePath = name => dataDir + "/" + name;

exports.getDataDir_ = () =>
  readConfig().then(config => {
    dataDir = config.dataDir;
    return dataDir;
  });

exports.setDataDir = dir => () => {
  dataDir = dir;
  TauriFS.createDir(getFilePath("notes"));
  writeConfig({ dataDir });
};

exports.readFile_ = file => () => readFile(getFilePath(file));

exports.writeFile_ = file => contents => () =>
  writeFile(getFilePath(file), contents);

exports.removeFile_ = file => () => removeFile(getFilePath(file));

exports.openDialog_ = () =>
  TauriDialog.open({
    directory: true
  });
