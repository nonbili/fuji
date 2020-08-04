/**
 * Because metascraper can't be run inside browser, use DOMParser to get page
 * title and og image. See also https://github.com/rnons/meta-proxy/ and
 * https://github.com/mozilla/page-metadata-parser.
 */
export const parseMeta = (html, origUrl) => {
  const parser = new DOMParser();
  const doc = parser.parseFromString(html, "text/html");
  const ogImage = doc.head.querySelector('meta[property="og:image"]');
  const image = (ogImage && ogImage.getAttribute("content")) || null;
  const ogUrl = doc.head.querySelector('meta[property="og:url"]');
  const url = (ogUrl && ogUrl.getAttribute("content")) || origUrl;
  return {
    title: doc.title,
    image,
    url
  };
};
