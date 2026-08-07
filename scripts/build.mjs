import { cp, mkdir } from "node:fs/promises";
import { build } from "esbuild";

await mkdir("public", { recursive: true });
await cp("site/index.html", "public/index.html");
await cp("site/styles.css", "public/styles.css");
await build({
  entryPoints: ["site/app.mjs"],
  bundle: true,
  format: "esm",
  minify: true,
  outfile: "public/app.js",
  sourcemap: false,
  target: ["es2022"],
});
