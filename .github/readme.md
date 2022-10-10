# iex.run

## Run Windows scripts anywhere!

iex.run is a a powershell-based, ultra-minimalist script bootstrapper. iex.run can turn a Github Pages repository into an online script toolbox that you can easily access from any unmanaged, online Windows endpoint with as few keystrokes as possible; and using 'Magic URLs' you can easily guide other users to do the same. 

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
>powershell syntax:  
>curl.exe iex.run/alphabet | iex  
  
>cmd.exe synatx (works in powershell as well):  
>curl iex.run | cmd alphabet  
  
### 2. Using the stub script launcher (Only after step 1 has been run once previously on an endpoint)
### 3. Using the stub script launcher in your own scripts or scripting engine.
### 4. Providing Magic URLs to others via email, teams or other message services.
### 5. Optional: 'Uninstall' iex.run from the endpoint when you are done. (Deletes all previously downloaded files including the stub script launcher)

## Setting up your own iex.run is easy!

1. Fork this repo
2. (Optional but recommended) purchase a short vanity URL like 'iex.run'. Get a .run domain if you wanna be cool like me.
3. Set up the forked repo as a Github Page using the vanity URL purchased above.
4. Update mandatory configs and preferences in the /etc/+main.config file.
5. Upload powershell scripts, batch files, or small binaries to the /scripts folder
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
- Relies on github unauthenticated API which is rate-limited (PLEASE Use it sparingly per unique public IP!) 
- Stub App cannot set the path variable when invoked from powershell;  
   >Workarounds:  
   -Launch stub app from cmd.exe instead  
   -type out the full invocation from powershell once to initialize (curl.exe iex.run | iex)  
   -manually add iex.run download location to user $path (note; this entry will not be removed by uninstall script)  
    
- stub helper script can only be used programatically inside .ps1 files and not batch files  
- iex.run assumes HTTPS is not enforced in Github Pages to require fewer keystrokes; it will not work if Github Pages enforces HTTPS.

## todo:

- Add error message when no matching file found; trying built-in command instead  
- Add error on multiple matches and list them out.  
- skip redownload if the sha alternate file stream matches  
- setup backup.config  
- setup main.config  
- refactor 404.html to use external backup.config and main.config  
- add URL decoding on parameters to allow for illegal URL chars 
- Have stub script replace spaces with quesiton marks automatically for parameters.  
- refactor cumbersome string manipulation  
- fill in readme details on steps on setup  
- support for powershell core / posh?  


