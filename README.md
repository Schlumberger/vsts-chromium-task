# VSTS Chromium Build Task [![Visual Studio Marketplace](https://vsmarketplacebadge.apphb.com/version-short/schlumberger.chromium.svg)](https://marketplace.visualstudio.com/items?itemName=schlumberger.chromium-build-tasks-Preview)

This task automates the Process of Installing Chromium on your Hosted Build Agent in VSTS so that you can run your javascript tests with a headless browser.

The environment variables CHROMIUM_BIN and CHROME_BIN will be set, so that tools like karma-chrome-launcher will work out of the box.

Sample Karma headless configuration:

```
    customLaunchers: {
      ChromeHeadless: {
        base: 'Chrome',
        flags: [
          '--headless',
          '--disable-gpu',
          // Without a remote debugging port, Google Chrome exits immediately.
          '--remote-debugging-port=9222',
        ],
      }
    }
```

Full documentation is available on [http://vsts-chromium-task.readthedocs.io](http://vsts-chromium-tasks.readthedocs.io)

## Getting the Tools

 You can [install from the Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=schlumberger.chromium-build-tasks-Preview) 





