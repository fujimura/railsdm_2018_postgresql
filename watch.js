const fs = require("fs");
const { execSync } = require("child_process");
const path = require("path");
const puppeteer = require("puppeteer");

const htmlToPdf = async src => {
  const browser = await puppeteer.launch();

  try {
    const dest = `${path.basename(src)}.pdf`;
    const page = await browser.newPage();
    await page.goto(`file://${src}`);
    await page.pdf({
      path: dest,
      width: 1024,
      height: 768
    });
    return dest;
  } finally {
    browser.close();
  }
};

fs.watch("./", async (eventType, filename) => {
  if (filename && path.extname(filename) == ".md") {
    const f = `${path.basename(filename)}.html`;
    console.log(eventType, filename, f);
    execSync(`pandoc -t slidy -s ${filename} -o ${f}`);
    //execSync(`open ${f}`);
    const pdfPath = await htmlToPdf(path.resolve(f));
    execSync(`open ${pdfPath}`);
  }
});
