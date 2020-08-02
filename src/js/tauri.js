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

export const readLinks = dir =>
  tauriOn
    ? TauriFS.readDir(dir).then(files =>
        Promise.all(files.map(file => TauriFS.readTextFile(file.path)))
      )
    : (() => {
        const keys = Object.keys(localStorage).filter(x => x.startsWith(dir));
        return Promise.resolve(keys.map(x => localStorage.getItem(x)));
      })();

export const readFile = file =>
  tauriOn
    ? TauriFS.readTextFile(file)
    : (() => {
        const data = localStorage.getItem(file);
        return data ? Promise.resolve(data) : Promise.reject("");
      })();

const writeFile = (path, contents) =>
  tauriOn
    ? TauriFS.writeFile({ path, contents })
    : Promise.resolve(localStorage.setItem(path, contents));

export const writeJson = (path, obj) =>
  writeFile(path, JSON.stringify(obj, null, 2));

export const removeFile = file =>
  tauriOn
    ? TauriFS.removeFile(file).then(
        () => {},
        () => {}
      )
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
    ? TauriFS.writeFile({ path: "config.json", contents }, appDirOption)
    : Promise.resolve(localStorage.setItem("fuji", contents));
};
