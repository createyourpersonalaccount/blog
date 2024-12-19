const fs = require('fs');
const html_entities = require('html-entities');
const cheerio = require('cheerio');
const hljs = require('highlight.js');

if (process.argv.length <= 2) {
    console.log('Usage: node colorize-source-code.js [HTML file, ...]');
    process.exit(0);
}

try {
    for(let i = 2; i < process.argv.length; ++i) {
        let modified = false;
        const file = process.argv[i];
        const buffer = fs.readFileSync(file);
        const $ = cheerio.loadBuffer(buffer);
        $('div.org-src-container').each((_, divElement) => {
            $(divElement).find('pre.src').each((_, preElement) => {
                const language = preElement.attribs.class.split('-').pop();
                $(preElement).html(
                    hljs.highlight(
                        html_entities.decode($(preElement).html()),
                        {language}
                    ).value
                );
                modified = true;
            });
        });
        if(modified) {
            fs.writeFileSync(file, $.html());
        }
    }
} catch({name, message}) {
    console.error(name, message);
    process.exit(1);
}

process.exit(0);
