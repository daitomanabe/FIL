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

// Copy animation gif
const gifSource = path.resolve(projectRoot, '../fil_of_app/fil_logo_animation.gif');
const gifDest = path.join(projectRoot, 'public', 'assets', 'fil_logo_animation.gif');
if (fs.existsSync(gifSource)) {
    fs.copyFileSync(gifSource, gifDest);
    console.log(`Copied animation gif to ${gifDest}`);
}

sources.forEach(src => {
    if (fs.existsSync(src.path)) {
        let content = fs.readFileSync(src.path, 'utf-8');

        // Fix image link for fil_of_app
        if (src.name === 'fil_of_app') {
            content = content.replace('(fil_logo_animation.gif)', '(assets/fil_logo_animation.gif)');
        }

        fs.writeFileSync(src.dest, content);
        console.log(`Copied ${src.name} README to ${src.dest}`);
    } else {
        console.warn(`Warning: ${src.name} README (src.path) not found. Creating empty placeholder.`);
        fs.writeFileSync(src.dest, `## ${src.name}\n\nNo README available.`);
    }
});
