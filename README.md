[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://img.shields.io/github/license/gvatsal60/Linux-All-In-One-Update-Script)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-Yes-green.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/graphs/commit-activity)
[![GitHub issues](https://img.shields.io/github/issues/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/issues/)
[![GitHub forks](https://img.shields.io/github/forks/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/network/)
[![GitHub stars](https://img.shields.io/github/stars/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/stargazers)
[![GitHub pull-requests](https://img.shields.io/github/issues-pr/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/pull/)

# Linux-All-In-One-Update-Script 🍎🖥️ 
Update Linux and all its packages with a single script

> Inspired from the repo
[MacOS-All-In-One-Update-Script](https://github.com/andmpel/MacOS-All-In-One-Update-Script/).

This is a bash linux update script that updates all software that I could find to be updated, feel free to add more.

## Run

To execute just run:

```sh
curl -sS https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/master/update_all.sh | sudo bash
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

- 🐧 Linux Package Update (`apt/dnf/yum/pacman`)
- 🧑‍💻 VS Code Extensions (`code`)
- 📦 Node Package Manager (`npm`)
- 💎 RubyGems (`gem`)
- 🧶 Yarn (`yarn`)
- 🐍 Python3 (`pip3`)
