[![Test Shell Script](https://github.com/gvatsal60/Linux-All-In-One-Update-Script/actions/workflows/TestShellScript.yml/badge.svg)](https://github.com/gvatsal60/Linux-All-In-One-Update-Script/actions/workflows/TestShellScript.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)]([https://gvatsal60/licenses/Apache-2.0](https://img.shields.io/github/license/gvatsal60//Linux-All-In-One-Update-Script)

# Linux-All-In-One-Update-Script 🍎🖥️ 
Update Linux and all its packages with a single script

> Inspired from the repo
[MacOS-All-In-One-Update-Script](https://github.com/andmpel/MacOS-All-In-One-Update-Script/).

This is a bash linux update script that updates all software that I could find to be updated, feel free to add more.

## Run

To execute just run:

```sh
sh update_all.sh
```

To source and then use individual update-* functions first
comment out the command at the bottom of the file and run:

```sh
source ./update_all.sh
```

If you want to use this command often copy it to directory that you
have in PATH variable (check with `echo $PATH`) like this:

```sh
USER_SCRIPTS="${HOME}/.local/bin"
mkdir -p $USER_SCRIPTS
cp ./update_all.sh $USER_SCRIPTS/update_all
chmod +x $USER_SCRIPTS/update_all
```

and now you can call the script any time :)


## Updates

Currently including:

- 🖥️ Linux Package Update (`brew`)
- 🧑‍💻 VS Code Extensions (`code`)
- 📦 Node Package Manager (`npm`)
- 💎 RubyGems (`gem`)
- 🧶 Yarn (`yarn`)
- 🐍 Python3 (`pip3`)
