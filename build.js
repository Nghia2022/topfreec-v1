console.log('Building JavaScript...');
const esbuild = require('esbuild');
const glob = require('glob');

const minify = process.argv.includes('--minify') > 0 ? true : false;

esbuild.build({
  entryPoints: glob.sync('app/javascript/packs/*.*'),
  bundle: true,
  sourcemap: true,
  minify,
  outdir: 'app/assets/builds',
  publicPath: 'assets',
})
.catch((e) => process.exit(1));
console.log('Done.');
