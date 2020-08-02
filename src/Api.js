const TauriHttp = require("tauri/api/http").default;

const { parseMeta } = require("../../src/js/meta-proxy");
const { tauriOn } = require("../../src/js/tauri");

exports.getMeta_ = url =>
  async function() {
    if (tauriOn) {
      const html = await TauriHttp.get(url, {
        responseType: TauriHttp.ResponseType.Text
      });
      return parseMeta(html, url);
    } else {
      const res = await fetch("https://meta-proxy.herokuapp.com?q=${url}");
      return res.json();
    }
  };
