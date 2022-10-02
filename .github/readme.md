# iex.run

## iex.run is an ultra-minamalist script bootstrapper.

iex.run will turn a Github Pages repository into an online script toolbox that you can easily access from any unmanaged, online Windows endpoint with as few keystrokes as possible; and with Magic URLs you can easily guide other end-users to do the same. 

It works based on a polyglot 404.HTML page that also contains a Powershell script, along with an optionally downloaded helper 'stub script launcher' to reduce keystrokes even further after first invocation on an endpoint.

## Test it now by playing a little game:
https://iex.run/1kbrl

## Getting started is easy:

1. Fork this repo
2. (Optional but recommended) purchase a short vanity URL like 'iex.run'
3. Set up the forked repo as a Github Page using the vanity URL
4. Update mandatory configs and preferences in .conf file.
5. Upload powershell scripts, batch files, or small binaries to the root of the github repo
6. Launch those scripts from any Windows endpoint using the simple iex.run syntax, the stub script launcher, or Magic URLs.

## How to use:
### 1. Basic Invocation using curl.exe.
### 2. Using the stub script launcher (Only after step 1 has been run once previously on an endpoint)
### 3. Use the stub script launcher in your own scripts.
### 4. Providing Magic URLs to others.
### 5. Optional: 'Uninstall' iex.run from the endpoint when you are done. (Deletes all previously downloaded files including the stub script launcher)

## FAQ

### 1. Is this a good idea?

Probably not, it teaches end users very bad security practices.

But I find it very convienient in particular cases, so use it at your own risk : )

    
### 2. Why not just use scoop, or winget, or chocolatey?

Those are all more suited to full applications and require install. iex.run is built on pure vanilla powerhell and HTML so requires no install and runs in most Windows machines out of the box.
It can also be used to setup/install those full-feature package managers in a super easy fashion.




## todo:

-Add error message when no matching file found; trying built-in command instead

-setup default.conf

-setup .conf

-use for-each to download all matches

-refactor 404.html to use config files

-create included uninstall script

-refactor cumbersome string manipulation

-polishing on HTML page

-add a wiki for steps on setup

-support for powershell core / posh?


