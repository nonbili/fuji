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

export const writeFile = (file, contents) =>
  tauriOn
    ? TauriFS.writeFile({ file, contents })
    : Promise.resolve(localStorage.setItem(file, contents));
