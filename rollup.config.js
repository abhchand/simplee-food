import copy from 'rollup-plugin-copy';
import outputManifest from 'rollup-plugin-output-manifest';
import scss from 'rollup-plugin-scss';
import { uglify } from 'rollup-plugin-uglify';

const isProduction = process.env.NODE_ENV === 'production';

const path = require('path');
const SRC_DIR = path.resolve(__dirname, 'app', 'frontend');
const PUBLIC_DIR = path.resolve(__dirname, 'public');

const config = {
  input: `${SRC_DIR}/js/index.js`,
  output: {
    // scss plugin uses `assetFileNames` for its naming pattern
    assetFileNames: '[name]-[hash][extname]',
    // This only minifies the rollup boilerplate code, not any user code
    compact: true,
    dir: PUBLIC_DIR,
    entryFileNames: 'application-[hash].js',
    format: 'iife',
    name: 'SimpleeFood'
  },
  watch: {
    chokidar: {
      paths: 'app/frontend/**/*'
    }
  },
  plugins: [
    scss({
      // The name of the output CSS file, but it will be transformed to fit
      // the pattern specified by `assetFileNames` above
      name: 'application.css',
      outputStyle: isProduction ? 'compressed' : null
    }),
    copy({
      targets: [{ src: 'app/frontend/images/**/*', dest: 'public/images' }]
    }),
    outputManifest()
  ]
};

if (isProduction) {
  config.plugins.push(uglify());
}

export default config;
