set -e

spago bundle-module -m Main -t output/Main/index.js
mkdir -p dist
cp index.html dist
NODE_ENV=production yarn build:css
yarn esbuild --bundle --minify --outdir=dist main.js
tauri build
