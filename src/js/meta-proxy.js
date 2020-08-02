/**
 * Because metascraper can't be run inside browser, use DOMParser to get page
 * title and og image. See also https://github.com/rnons/meta-proxy/ and
 * https://github.com/mozilla/page-metadata-parser.
 */
export const parseMeta = (html, url) => {
  const parser = new DOMParser();
  const doc = parser.parseFromString(html, "text/html");
  return {
    title: doc.title,
    image: "",
    url
  };
};
