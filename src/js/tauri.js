/**
 * A module to make Fuji run with or without tauri.
 *
 * When running in tauri, use tauri APIs to read/write files.
 * Otherwise, use localStorage.
 */

import * as TauriFS from "tauri/api/fs";

const userAgent = navigator.userAgent.toLowerCase();

// A hacky way to detect if running on tauri.
export const tauriOn = !(
  userAgent.includes("firefox") || userAgent.includes("chrome")
);

export const readFile = file =>
  tauriOn
    ? TauriFS.readTextFile(file)
    : (() => {
        const data = localStorage.getItem(file);
        return data ? Promise.resolve(data) : Promise.reject("");
      })();

const writeFile = (file, contents) =>
  tauriOn
    ? TauriFS.writeFile({ file, contents })
    : Promise.resolve(localStorage.setItem(file, contents));

export const writeJson = (file, obj) =>
  writeFile(file, JSON.stringify(obj, null, 2));

export const removeFile = file =>
  tauriOn
    ? TauriFS.removeFile(file)
    : Promise.resolve(localStorage.removeItem(file));

if (tauriOn) {
  // Init fuji filder inside the system config folder. e.g. `~/.config/fuji` on
  // Linux.
  const configDirOption = { dir: TauriFS.Dir.Config };
  TauriFS.readDir("fuji", configDirOption).then(
    () => {},
    () => {
      TauriFS.createDir("fuji", configDirOption);
    }
  );
}

const appDirOption = { dir: TauriFS.Dir.App };

export const readConfig = () =>
  tauriOn
    ? TauriFS.readTextFile("config.json", appDirOption).then(JSON.parse)
    : Promise.resolve({ dataDir: "fuji" });

export const writeConfig = config => {
  const contents = JSON.stringify(config, null, 2);
  tauriOn
    ? TauriFS.writeFile({ file: "config.json", contents }, appDirOption)
    : Promise.resolve(localStorage.setItem("fuji", contents));
};
