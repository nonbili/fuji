exports.get_ = url => () => {
  return fetch(url).then(res => res.json());
};
