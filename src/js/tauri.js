/**
 * A module to make Fuji run with or without tauri.
 *
 * When running in tauri, use tauri APIs to read/write files.
 * Otherwise, use localStorage.
 */

import * as TauriFS from "tauri/api/fs";

const tauriOn = !!window.tauri;

console.log({ tauriOn });
TauriFS.readTextFile("fuji/store.json")
  .then(x => console.log("resolve", x))
  .catch(x => console.warn("reject", x));

export const readFile = file => {
  // console.log("readFile", window.tauri, TauriFS.readTextFile);
  return window.tauri || true
    ? TauriFS.readTextFile(file)
    : Promise.resolve(localStorage.getItem(file)) || "";
};

export const writeFile = (file, contents) =>
  tauriOn
    ? TauriFS.writeFile({ file, contents })
    : Promise.resolve(localStorage.setItem(file, contents));
