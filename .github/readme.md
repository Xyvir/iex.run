<!--- readme.md MUST be located in sub folder .github or else 404.html will be super-ceded by readme.md which defeats the purpose of magic URLs --->

# iex.run

## Quickly run Windows scripts anywhere!

iex.run is a vanilla-powershell-based, ultra-minimalist script bootstrapper.  
  
iex.run can turn a Github Pages repository into an online script toolbox that you can easily access from any unmanaged, online Windows endpoint with as few keystrokes as possible; and using 'Magic URLs' you can easily guide other users to do the same. 

It works by way of a polyglot 404.HTML page / Powershell script, alongside an optionally-downloaded helper 'stub script launcher' to reduce keystrokes even further (after the first initial invocation on an endpoint.)

## Test it now by visiting the 'Magic URL' below, and then follow the instructions to play a little game.  
https://iex.run/3kbrl  
  
### You can also launch it interactively in cmd.exe or powershell; try the following in a fresh cmd.exe terminal:  
``curl iex.run | cmd``   
``iex.run 3kbrl``  
   
>Both methods download and launch the 3kbrl.bat found in the /scripts folder above.    
>  
>Use the WASD to move, try to pick up gold and extra fuel before your torch goes out.  
>game inspired by https://github.com/tapio/1kbrl  
  

## How to use:  
### 1. Interactively from Powershell or cmd.exe:  
#### Syntax Chart
powershell:
```
curl.exe iex.run/command?param1?param2?@Metaparam1@Metaparam2 | iex
curl.exe -L xgumby.github.io/command?param1?param2?@Metaparam1@Metaparam2 | iex
```
cmd:
```
curl iex.run/command?parameter1?parameter2?@Metaparameter1@Metaparameter1 | cmd
curl -L xgumby.github.io/command?parameter1?parameter2?@Metaparameter1@Metaparameter1 | cmd
```
>Note that the middle portion of the command is identical to it's magic URL, we suggest prepending https:// so most things will automtaically convert it to a hyperlink.
#### Examples 
**Vanity Domain Basic Invocation:**  
powershell:  
``curl.exe iex.run/alphabet | iex``
  
cmd.exe:  
``curl iex.run/alphabet | cmd ``  

  
**Non-Vanity Domain Basic Invocation: ('https://' or -L mandatory)**  
powershell syntax:  
``curl.exe -L xgumby.github.io/alphabet | iex ``  
or  
``curl.exe https://xgumby.github.io/alphabet | iex ``  
   
cmd.exe syntax:  
``curl -L xgumby.github.io/alphabet | cmd ``  
or  
``curl https://xgumby.github.io/alphabet | iex``  
     
### 2. Using the stub script launcher (Only after step 1 has been run once previously on an endpoint)
``` iex.run alphabet ```
### 3. Using the stub script launcher in your own scripts or scripting engine.
```
## recurse.ps1; example of how you can call iex.run-hosted scripts from other scripts.
## in your scripting engine call 'curl.exe iex.run/recurse | iex' to also run alphabet.cmd and paramtest.cmd in order.
$Env:testvar = "Hello World"
iex.run alphabet
iex.run paramtest?1
iex.run passvar
```
### 4. Providing Magic URLs to others via email, teams or other message services.
https://iex.run/alphabet

### 5. Optional: 'Uninstall' iex.run from the endpoint when you are done. (Deletes all previously downloaded files including the stub script launcher)
`` iex.run @uninstall``

# Additional Features:

## built-in commands are supported, and 'poison characters' can be url-encoded in the command OR paraemeters as needed. This allows you to
## provide magic URLs for built-in commands.  
  
``ipconfig /all``  
can be run with:  
https://iex.run/ipconfig?/all  

## Arbitrary arguments are supported by using '?' as a delimiter.
iex.run will replace all '?' with spaces when the command is launched. All forward-slashes '/' past the first quesiton mark are preserved and passed as an argument.
  
> Example:  
``curl.exe iex.run/alphabet?23-30?35-50 | iex``  
> is the same as:  
``alphabet.cmd 23-30 35-50``


  
``Get-NetIPConfiguration | select "InterfaceAlias","InterfaceDescription" | out-gridview; pause``   
enocdes to:   
https://iex.run/Get-NetIPConfiguration%20%7C%20select%20%22InterfaceAlias%22%2C%22InterfaceDescription%22%20%7C%20out-gridview%3Bpause
  
## 'Metaparameters' can modify the default behaviors of iex.run on an as-needed basis.  
Use '@' signs to specify metaparemeters which will not be passed to the command, but rather will toggle the default settings by the same name in the config.html.

``curl.exe iex.run/alphabet?23-30?35-50?@Debugvars | iex``  
`` ``  
### Metaparmeters:
```
NoStub                 # Do not download stub script  
NoWildcard             # Do not match command on wildcard  
NoExecute              # Download Script only. 
NewWindow              # opens script in a new window
Admin                  # Run script elevetated.  
Hidden                 # hide powershell window  
cat                    # prints script text only, does not download or execute  
type                   # same as cat  
help                   # same as cat except filters to line comments starting with ##, or :: 
                       # so you can add custom iex.run help reminders in the comments of your scripts.
DLRemote               # Download remote file as specified via URL-encoded main command OR recursive script pre-set variable $DLRemote
NoClipboard            # Do not copy MagicURL to clipboard  
DebugVars              # show all vars created  
KeepVars               # do not delete any iex variables after script runs.  
Uninstall              # Run uninstall script after  
UninstallAll           # Run uninstall script after on all
```

## 'Remote Download' feature support via enviromental variable or meta-parameter:

This will tell iex.run to install Opera by using ninte:

``curl.exe iex.run/https%3A%2F%2Fninite.com%2Fopera%2Fninite.exe?@DLRemote | iex``

# Setting up your own iex.run instance is easy!

1. Optional, but Recommended: Purchase a short, pithy, vanity domain name like 'iex.run'.
 - Make sure it is unique for a github repo name. Search like the following to check:
 > "foo.run" in:name fork:true
  (Get a .run ending if you wanna be cool like me.)
  (3 letter names are about as short as you can go w/o paying ridiculous pricing ie: 'foo.run')  
2. Fork this repository and name it accordingly:
 - If you purchased a vanity domain, name the forked repo exactly the same as the apex vanity name. 'foo.run'
 - OTHERWISE, name the forked repo '<your-github-username>.github.io' ie: 'xgumby.github.io'
3. Set up the forked repo as a Github Page, deploy from a branch, main / root
4. Optional: Verify your vanity domain with Github, then configure within Github pages, then disable 'enforce HTTPS'.
5. Optional: Set Custom iex.run default runtime options and/or webpage banner within /customization folder.
6. Optional: If using a non-vanity github.io domain, delete the CNAME file.
7. Optional: IF you want to repurpose any of the existing example scripts, please replace iex.run with your own domain name. 
8. Upload powershell scripts, batch files, or small binaries to the /scripts folder
9. Launch those scripts uploaded in step 5 from most any Windows endpoint using the interactive console syntax, the stub script launcher, or Magic URLs as explained above.

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
   >Workaround: Use powershell invocation instead for user input scripts, or @NewWindow meta-parameter

At this point iex.run does basically everything I would want it to, there are a few other improvements I can think of but I may not get to these for awhile:

## todo:  
only write alternate-file stream info if file succesfully downloads (if (download command) {write sha}
  
## possible todo:

- review / refactor cumbersome string manipulation
- Allow for multi-match downloads if @Noexecute is true
- have iex.run respect working directory when script runs? (in case script does something in the current directory and cares about this)
- Add builtin 'rpau' meta-parameter? (either by piggy-backing off RPAU.exe or figuring out how to do this myself natively in powershell.)
- Add admin/global install and uninstall options.
- Add support for programatically adding public/iex.golf to %PATH% permanently. 

[Buy me a coffee!](https://www.paypal.com/donate/?hosted_button_id=RCQNK9RFDYQEG)
