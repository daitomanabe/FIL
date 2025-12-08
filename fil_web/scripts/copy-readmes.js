import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const projectRoot = path.resolve(__dirname, '..');
const publicDataDir = path.join(projectRoot, 'public', 'data');

if (!fs.existsSync(publicDataDir)) {
    fs.mkdirSync(publicDataDir, { recursive: true });
}

const sources = [
    {
        name: 'fil_of_app',
        path: path.resolve(projectRoot, '../fil_of_app/README.md'),
        dest: path.join(publicDataDir, 'fil_of_app.md')
    },
    {
        name: 'fil_screensaver',
        path: path.resolve(projectRoot, '../fil_screensaver/README.md'),
        dest: path.join(publicDataDir, 'fil_screensaver.md')
    }
];

sources.forEach(src => {
    if (fs.existsSync(src.path)) {
        fs.copyFileSync(src.path, src.dest);
        console.log(`Copied ${src.name} README to ${src.dest}`);
    } else {
        console.warn(`Warning: ${src.name} README (src.path) not found. Creating empty placeholder.`);
        fs.writeFileSync(src.dest, `## ${src.name}\n\nNo README available.`);
    }
});
