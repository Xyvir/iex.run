<!--- readme.md MUST be located in sub folder .github or else 404.html will be super-ceded by readme.md which defeats the purpose of magic URLs --->

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
### 1. Interactively from Powershell or cmd.exe:  
  
 
**Vanity Domain Basic Invocation:**  
powershell syntax:  
``curl.exe iex.run/alphabet | iex``
  
cmd.exe syntax:  
``curl iex.run/alphabet | cmd ``  

  
**Non-Vanity Domain Basic Invocation: ('https://' mandatory)**  
powershell syntax:  
``curl.exe -L xgumby.github.io/alphabet | iex ``  
or  
``curl.exe https://xgumby.github.io/alphabet | iex ``  
   
cmd.exe syntax:  
``curl -L xgumby.github.io/alphabet | cmd ``  
or  
``curl https://xgumby.github.io/alphabet | iex``  
     
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

1. Optional, but Recommended: Purchase a short, pithy, vanity domain name like 'iex.run'. Get a .run ending if you wanna be cool like me. (3 letter names are about as short as you can go w/o paying ridiculous pricing, ie: 'foo.run')  
2. Fork this repository and name it accordingly:
 - If you purchased a vanity domain, name the forked repo the same as the apex vanity name.
 - OTHERWISE, name the forked repo '<your-github-username>.github.io' ie: 'xgumby.github.io'
3. Set up the forked repo as a Github Page, deploy from a branch, main / root
4. Optional: Verify your vanity domain with Github, then configure within Github pages, then disable 'enforce HTTPS'.
5. Optional: Set Custom iex.run runtime options and webpage banner within /customization folder.
6. Optional: If using a non-vanity github.io domain, delete the CNAME file. 
7. Upload powershell scripts, batch files, or small binaries to the /scripts folder
8. Launch those scripts uploaded in step 5 from most any Windows endpoint using the interactive console syntax, the stub script launcher, or Magic URLs as explained above.

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
- HTTPS is enforced on non-vanity domains, so https:// or -L must be supplied to those curl invocations
- cmd invocations seems to block user input (due to how far down the matrix it goes)  
   >Workaround: Use powershell invocation instead for user input scripts  
  
## todo:

- Have stub script replace spaces with quesiton marks automatically for parameters, attepmt to run local commands when run offline.
- finish remaining planned meta-parameters
- add metaparameter instructions to readme.
- add 'external download' and run option via metaparemeter OR other recursive scripts
- extra trailing spaces after domain name breaks things for some reason  
- write sha to stub script AFS and skip download if current.
- review / refactor cumbersome string manipulation  
- have iex.run respect working directory when script runs (in case script does something in the current directory and cares about this)
- Add 'UninstallAll' parameter since iex.runs can live side-by-side (look up stubs by *.*.cmd, look up folders by *.*)
