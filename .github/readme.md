# iex.run

## a powershell-based, ultra-minamalist script bootstrapper.

iex.run can turn a Github Pages repository into an online script toolbox that you can easily access from any unmanaged, online Windows endpoint with as few keystrokes as possible; and using 'Magic URLs' you can easily guide other users to do the same. 

It works by way of a polyglot 404.HTML page / Powershell script, alongside an optionally-downloaded helper 'stub script launcher' to reduce keystrokes even further after first invocation on an endpoint.

## Test it now by visiting the 'Magic URL' below, and following the instructions to play a little game.  
https://iex.run/1kbrl  
  
>This demo launches the 1kbrl.exe found in the iex.run repo above.  
>Use the WASD to move, try to pick up gold and extra fuel before your torch goes out.  
>credit to https://github.com/tapio/1kbrl

## Arbitrary arguments are supported by using '?' as a delimiter.
iex.run will replace all '?' with spaces when the command is launched. All forward-slashes '/' past the first quesiton mark are preserved and passed as an argument.

> Example:  
> curl.exe iex.run/alphabet?23-30?35-50 | iex  
> is the same as:  
> alphabet.cmd 23-30 35-50  

## How to use:
### 1. Basic Invocation using curl.exe from powershell or cmd.exe.
### 2. Using the stub script launcher (Only after step 1 has been run once previously on an endpoint)
### 3. Using the stub script launcher in your own scripts or scripting engine.
### 4. Providing Magic URLs to others via email, teams or other message services.
### 5. Optional: 'Uninstall' iex.run from the endpoint when you are done. (Deletes all previously downloaded files including the stub script launcher)

## Setting up your own iex.run is easy!

1. Fork this repo
2. (Optional but recommended) purchase a short vanity URL like 'iex.run'. Get a .run domain if you wanna be cool like me.
3. Set up the forked repo as a Github Page using the vanity URL purchased above.
4. Update mandatory configs and preferences in the main.config file.
5. Upload powershell scripts, batch files, or small binaries to the root of the github repo
6. Launch those scripts from any Windows endpoint using the simple iex.run syntax, the stub script launcher, or Magic URLs.

## FAQ

### 1. Is this a good idea?

Probably not, it teaches end users very bad security practices.

But I find it very convienient in particular cases, so use it at your own risk : )

    
### 2. Why not just use git, scoop, winget, or chocolatey?

Those are all more suited to full applications / development, each have their own pre-requesites and require install. iex.run is built on pure vanilla powerhell and HTML so requires no install and runs in most Windows machines out of the box.
It can also be used to customize setup and install scripts for those full-feature package managers.

If you are an MSP, iex.run is not meant to be a replacement for a script engine or RMM but a quick bootstrapper to help quickly get unmanaged PCs managed, or to otherwise allow end-users to easily run quick ad-hoc scripts themselves.


## Current Limitations:
- Stub App cannot set the path variable when invoked from powershell;  
   >Workarounds:  
   -Launch stub app from cmd.exe instead  
   -type out the full invocation from powershell once to initialize (curl.exe iex.run | iex)  
   -manually add iex.run download location to user $path (note; this entry will not be removed by uninstall script)  
   
- cmd.exe invocation can only be used to install the stub script; 'curl iex.run/sciptname | cmd' will ignore scriptname  
   >Workarounds:  
    Use 'curl iex.run | cmd' to install the stub script first then 'iex.run sciptname' to download and run the script.
    
- stub helper script can only be used programatically inside .ps1 files and not batch files.  
- iex.run assumes HTTPS is not enforced in Github Pages to require fewer keystrokes; it will not work if Github Pages works.

## todo:

- Add error message when no matching file found; trying built-in command instead
- Add error on multiple matches and list them out.
- skip redownload if the sha alternate file stream matches
- setup backup.config  
- setup main.config  
- add URL decoding on parameters to allow for illegal URL chars
- refactor 404.html to use external config files AND embedded HTML files w/ iframes
- create included uninstall script  
- Have stub script replace spaces with quesiton marks automatically for parameters.
- refactor cumbersome string manipulation  
- fill readme details on steps on setup  
- break off 404 html using iframe and send parentl URL data to iframe child.
 (https://htmldom.dev/communication-between-an-iframe-and-its-parent-window/)
- support for powershell core / posh?  


