# Fuji (藤)

藤 means [Japanese wisteria](https://en.wikipedia.org/wiki/Wisteria_floribunda). It's also a desktop app to manage bookmarks and take notes.

## Features

- [x] Save a link with the og:image
- [x] Add notes to a link
- [ ] Add tags to a link
- [ ] Search saved links

## Install

Currently only deb package is released on https://github.com/nonbili/fuji/releases.

## Build from source

Fuji is written in PureScript Halogen, [tauri](https://github.com/tauri-apps/tauri) is used to package Fuji as a desktop app.

Prerequisites

- yarn or npm
- spago
- cargo

```
git clone https://github.com/nonbili/fuji
cd fuji
cargo install tauri-bundler
yarn
yarn build
```

An executable named `fuji` can be found inside the `src-tauri/target/release` folder.

## Development

```
git clone https://github.com/nonbili/fuji
cd fuji
yarn
yarn start:ps
yarn dev
```

Open `http://localhost:1234` in Firefox or Chrome. To run inside tauri, run `yarn tauri`.
