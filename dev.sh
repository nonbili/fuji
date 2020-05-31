set -e

mkdir -p dist
cp index.html dist/index.html
yarn build:css
yarn start
