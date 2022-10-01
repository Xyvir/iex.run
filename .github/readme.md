# iex.run

## iex.run is a lightweight script bootstrapper.

iex.run will turn a Github Pages repository into an online script toolbox that you can easily access from any unmanaged online Windows endpoint with as few keystrokes as possible; and easily give instructiosn for end-users to do the same via 'Magic URLs'. 

Test it now by playing a little game:
https://iex.run/1kbrl

Getting started is easy:

1. Fork this repo
2. (Optional but recommended) purchase a short vanity URL like 'iex.run'
3. Set up the forked repo as a Github Page using the vanity URL
4. Update mandatory configs and preferences in .conf file.
5. Upload powershell scripts, batch files, or small binaries to the root of the github repo
6. Launch scripts from any Windows endpoint using the simple iex.run syntax OR Magic URLs.

todo:
-setup default.conf
-setup .conf
-use for-each to download all matches
-refactor 404.html to use config files
-create included uninstall script
-refactor cumbersome string manipulation
-polishing on HTML page
-support for powershell core / posh?

