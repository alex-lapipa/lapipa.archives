import { cp, mkdir } from "node:fs/promises";

await mkdir("public", { recursive: true });
await cp("site/index.html", "public/index.html");
await cp("site/styles.css", "public/styles.css");

