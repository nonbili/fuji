const TauriDialog = require("tauri/api/dialog");
const TauriFS = require("tauri/api/fs");

const {
  readLinks,
  readFile,
  writeJson,
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
  TauriFS.createDir(getFilePath("links"));
  writeConfig({ dataDir });
};

exports.readLinks_ = dir => () => readLinks(getFilePath(dir));

exports.readFile_ = file => () => readFile(getFilePath(file));

exports.writeJson_ = file => json => () => writeJson(getFilePath(file), json);

exports.removeFile_ = file => () => removeFile(getFilePath(file));

exports.openDialog_ = () =>
  TauriDialog.open({
    directory: true
  });
