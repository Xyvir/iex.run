# iex.run

## Quickly run Windows scripts anywhere!

iex.run is a vanilla-powershell-based, ultra-minimalist script bootstrapper.  
  
iex.run can turn a Github Pages repository into an online script toolbox that you can easily access from any unmanaged, online Windows endpoint with as few keystrokes as possible; and using 'Magic URLs' you can easily guide other users to do the same. 

It works by way of a polyglot 404.HTML page / Powershell script, alongside an optionally-downloaded helper 'stub script launcher' to reduce keystrokes even further (after the first initial invocation on an endpoint.)

## Test it now by visiting the 'Magic URL' below, and then follow the instructions to play a little game.  
https://iex.run/1kbrl  
  
>This demo launches the 1kbrl.exe found in the iex.run repo above.  
>Use the WASD to move, try to pick up gold and extra fuel before your torch goes out.  
>credit to https://github.com/tapio/1kbrl


## How to use:
### 1. Basic Invocation using curl.exe from powershell:  
powershell syntax:  
>curl.exe iex.run/alphabet | iex  
  
cmd.exe syntax:cmd  
>curl iex.run/alphabet | cmd 
  
### 2. Using the stub script launcher (Only after step 1 has been run once previously on an endpoint)
### 3. Using the stub script launcher in your own scripts or scripting engine.
### 4. Providing Magic URLs to others via email, teams or other message services.
### 5. Optional: 'Uninstall' iex.run from the endpoint when you are done. (Deletes all previously downloaded files including the stub script launcher)

## Arbitrary arguments are supported by using '?' as a delimiter.
iex.run will replace all '?' with spaces when the command is launched. All forward-slashes '/' past the first quesiton mark are preserved and passed as an argument.

> Example:  
> curl.exe iex.run/alphabet?23-30?35-50 | iex  
> is the same as:  
> alphabet.cmd 23-30 35-50 

## Setting up your own iex.run instance is easy!

1. Purchase a short, pithy, vanity domain name like 'iex.run'. Get a .run ending if you wanna be cool like me. (3 letter names are about as short as you can go w/o paying ridiculous pricing.)  
2. Fork this repository and name it identically to the unique URL you purchased above.
3. Set up the forked repo as a Github Page using the vanity URL purchased above.
4. Optional : Set Custom iex.run Options and webpage banner within /customization folder.
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
- cmd invocations seems to block user input (due to how far down the matrix it goes)  
   >Workaround: Use powershell invocation instead for user input scripts  
  
## todo:

- skip re-download if the sha alternate file stream matches
- add external download and run option via metaparemeter OR other scripts
- Have stub script replace spaces with quesiton marks automatically for parameters.
- finish remaining planned meta-parameters
- review / refactor cumbersome string manipulation  
- fill in readme details more steps on setup
- add metaparameter instructions to readme.
- andd support and test for non-vanity urls (repo.github.io) 
- test parameters that contain quotes (fixed with encoding?)
- support for powershell core / posh?  


