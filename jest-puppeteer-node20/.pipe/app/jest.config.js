const common = require('./jest.common.config.js')

module.exports = {
    ...common,

    testFailureExitCode: 1//,
    // globalTeardown: "./global-teardown.js"
};
