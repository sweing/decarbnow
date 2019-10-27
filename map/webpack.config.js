const path = require('path');

module.exports = {
    entry: './main.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist')
    },
    mode: 'production',
    plugins: [],
    performance: {
        hints: false,
    },
    devtool: 'source-map'
};
