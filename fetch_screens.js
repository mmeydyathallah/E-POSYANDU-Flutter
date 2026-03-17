const https = require('https');
const fs = require('fs');
const execSync = require('child_process').execSync;

const API_KEY = 'AQ.Ab8RN6I4QNgc2a9x5XuRLNRVdho-NrPLw8wJDjJD7_G3U6OkoQ';
const PROJECT_ID = '4346466614196908066';
const SCREENS = [
    { id: '2380facb9bd74c02b860b275cc952104', name: 'Home Dashboard' },
    { id: '5298d3af77784d86aab7bf8b52518629', name: 'Toddler Data' },
    { id: '70e810dc36114d778bf7e21d5834e67a', name: 'Growth Tracker' },
    { id: '567a605b6951490d891d28e595f2de54', name: 'Input Data' },
    { id: '13c8ef0e1d9c42bd9c7c2912772a918b', name: 'Export & Reports' },
    { id: 'd9309e9946ec4da685eb8c6831d472e0', name: 'Register New Toddler' },
    { id: 'a46b56d85213493cbb843901019733ef', name: 'BLE Device Splash Screen' }
];

async function fetchScreenDetails(screen) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            jsonrpc: '2.0', id: 1, method: 'tools/call',
            params: {
                name: 'get_screen',
                arguments: {
                    name: `projects/${PROJECT_ID}/screens/${screen.id}`,
                    projectId: PROJECT_ID, screenId: screen.id
                }
            }
        });

        const options = {
            hostname: 'stitch.googleapis.com', path: '/mcp', method: 'POST',
            headers: { 'X-Goog-Api-Key': API_KEY, 'Content-Type': 'application/json', 'Content-Length': data.length }
        };

        const req = https.request(options, res => {
            let body = '';
            res.on('data', d => body += d);
            res.on('end', () => resolve(JSON.parse(body)));
        });
        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

async function run() {
    for (const s of SCREENS) {
        console.log(`Fetching details for: ${s.name}...`);
        try {
            const response = await fetchScreenDetails(s);
            const data = response.result.structuredContent;
            if (data && data.screenshot && data.screenshot.downloadUrl) {
                console.log(`Downloading image for ${s.name}...`);
                execSync(`curl -L -s "${data.screenshot.downloadUrl}" -o "stitch_exports/${s.name.replace(/ /g, '_')}.png"`);
            }
            if (data && data.htmlCode && data.htmlCode.downloadUrl) {
                console.log(`Downloading code for ${s.name}...`);
                execSync(`curl -L -s "${data.htmlCode.downloadUrl}" -o "stitch_exports/${s.name.replace(/ /g, '_')}.html"`);
            }
        } catch (e) {
            console.error(`Failed to fetch ${s.name}: ${e.message}`);
        }
    }
}

run();
