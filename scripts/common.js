const {exec} = require('child_process');

/*
 * 
 * Runs the build to create new dist scripts
 *
 * **/
async function runProductionInstall() {
    return new Promise((resolve, reject) => {
        exec('yarn install --frozen-lockfile --production', (err, stdout, stderr) => {
            if (err) return reject(stderr);
            return resolve(stdout);
        });
    });
}
/*
 *
 * 
 * Cleans the dist folder 
 *
 * **/
async function runClean() {
    return new Promise((resolve, reject) => {
        exec('yarn run clean', (err, stdout, stderr) => {
            if (err) return reject(stderr);
            return resolve(stdout);
        });
    });
}


/*
 * 
 * Runs the build to create new dist scripts
 *
 * **/
async function runBuild() {
    return new Promise((resolve, reject) => {
        exec('yarn run build', (err, stdout, stderr) => {
            if (err) return reject(stderr);
            return resolve(stdout);
        });
    });
}

module.exports = {
    runClean,
    runBuild,
    runProductionInstall
};
