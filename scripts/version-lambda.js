const packageJson = require('../package.json');
const {exec} = require('child_process');
const fs = require('fs').promises;
const common = require('./common');

/*
 * 
 * Generate a versioned zip file based on the package json
 *
 * **/
async function generateLambdaS3ZipFile() {
    const fileName = `deploy/main-${packageJson.version}.zip`;
    console.log('Creating new zip file...');
    return new Promise((resolve, reject) => {
        exec(`zip ${fileName} ../dist/ ../node_modules`, (err, stdout, stderr) => {
            if (err) return reject(stderr);
            if (stdout) {
                console.log(`File created. name: ${fileName}`);
                return resolve(stdout);
            }
        });
    });
}

async function main() {
    // Clean folders / files
    await common.runClean();

    // Run build 
    await common.runBuild();

    // Create new dist folder
    await fs.mkdir('deploy');

    // Generate 
    await generateLambdaS3ZipFile();
}

main();