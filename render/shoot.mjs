// scene.html をヘッドレス Chromium で開き、ポーズ列を 1 枚ずつ PNG に撮る
// usage: node shoot.mjs URL poses.json 出力先ディレクトリ 幅 高さ
// CHROMIUM_PATH を指定するとそのブラウザを使う（未指定なら Playwright が入れた Chromium）
import { chromium } from 'playwright-core';
import fs from 'fs';

const [, , url, posesFile, outDir, W, H] = process.argv;
const poses = JSON.parse(fs.readFileSync(posesFile, 'utf8'));
fs.mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch({
  executablePath: process.env.CHROMIUM_PATH || undefined,
  // GPU に依らず同じ絵になるよう、ソフトウェアの WebGL（SwiftShader）で描く
  args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});
const page = await browser.newPage({ viewport: { width: +W, height: +H } });
page.on('pageerror', (e) => { console.error('pageerror:', e.message); process.exit(1); });
await page.goto(`${url}?w=${W}&h=${H}`);
await page.waitForFunction(() => window.ready === true, null, { timeout: 120000 });
for (let i = 0; i < poses.length; i++) {
  await page.evaluate((p) => window.setPose(p), poses[i]);
  const name = poses[i].name || String(i).padStart(4, '0');
  await page.locator('canvas').screenshot({ path: `${outDir}/${name}.png` });
  if (i % 50 === 49) console.log(`  ${i + 1} / ${poses.length}`);
}
await browser.close();
