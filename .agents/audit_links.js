const fs = require('fs');
const path = require('path');

const htmlFiles = fs.readdirSync('.').filter(f => f.endsWith('.html'));
console.log('HTML files to audit:', htmlFiles);

let errors = [];

htmlFiles.forEach(file => {
  const content = fs.readFileSync(file, 'utf8');

  // Check href
  const hrefRegex = /href=["']([^"'#?]+)(?:[#?][^"']*)?["']/g;
  let match;
  while ((match = hrefRegex.exec(content)) !== null) {
    const target = match[1].trim();
    if (
      !target ||
      target.startsWith('http://') ||
      target.startsWith('https://') ||
      target.startsWith('mailto:') ||
      target.startsWith('tel:') ||
      target.startsWith('data:') ||
      target.startsWith('javascript:')
    ) {
      continue;
    }
    const resolved = path.resolve('.', target);
    if (!fs.existsSync(resolved)) {
      errors.push({ file, type: 'href', target });
    }
  }

  // Check src
  const srcRegex = /src=["']([^"'#?]+)(?:[#?][^"']*)?["']/g;
  while ((match = srcRegex.exec(content)) !== null) {
    const target = match[1].trim();
    if (
      !target ||
      target.startsWith('http://') ||
      target.startsWith('https://') ||
      target.startsWith('data:') ||
      target.startsWith('blob:') ||
      target.startsWith('javascript:')
    ) {
      continue;
    }
    const resolved = path.resolve('.', target);
    if (!fs.existsSync(resolved)) {
      errors.push({ file, type: 'src', target });
    }
  }
});

console.log('\n--- AUDIT RESULTS ---');
if (errors.length === 0) {
  console.log('ALL local href and src links exist!');
} else {
  console.log(`Found ${errors.length} broken reference(s):`);
  errors.forEach(e => console.log(`  [${e.file}] Broken ${e.type}: "${e.target}"`));
}
