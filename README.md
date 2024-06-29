# Linux All-In-One Update Script

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://img.shields.io/github/license/gvatsal60/Linux-All-In-One-Update-Script)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/gvatsal60/Linux-All-In-One-Update-Script/ShellCheck.yml)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-Yes-green.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/graphs/commit-activity)
[![GitHub pull-requests](https://img.shields.io/github/issues-pr/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/pull/)
[![GitHub issues](https://img.shields.io/github/issues/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/issues/)
[![GitHub forks](https://img.shields.io/github/forks/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/network/)
[![GitHub stars](https://img.shields.io/github/stars/gvatsal60/Linux-All-In-One-Update-Script.svg)](https://GitHub.com/gvatsal60/Linux-All-In-One-Update-Script/stargazers)

This repository contains a versatile shell script designed to streamline the update process for various components of a Linux system. Whether you're a seasoned Linux user or just getting started, this script aims to simplify the often tedious task of updating your system by combining multiple update commands into one convenient script.

> Inspired from the repo [MacOS-All-In-One-Update-Script](https://github.com/andmpel/MacOS-All-In-One-Update-Script/).

## Features

- **Comprehensive Updates**: Update all system packages, including installed applications, libraries, and system components, with a single command.
- **Package Manager Agnostic**: Compatible with popular package managers like APT (Debian/Ubuntu), DNF (Fedora), Pacman (Arch), and more, ensuring flexibility across different Linux distributions.
- **Customization**: Easily configurable options allow users to tailor the script to their preferences and specific system requirements.

## Usage

To start using this all-in-one update script, follow these simple steps:

### Quick Step

Run the following command in your terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/HEAD/update_all.sh | sh
```

### Manual Step

1. **Download the Script**: Clone this repository or download the `update.sh` script directly to your Linux system.

   ```sh
   curl -fsSL -o "$HOME/update.sh" https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/HEAD/update_all.sh
   ```

   or

   ```sh
   wget -O "$HOME/update.sh" https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/HEAD/update_all.sh
   ```

2. **Make it Executable**: Ensure the script has executable permissions. If necessary, grant execution permissions using the following command:

   ```sh
   chmod +x "$HOME/update.sh"
   ```

3. **Execute the Script**: Run the script from the terminal using the following command:

   ```sh
   ./$HOME/update.sh
   ```

   Follow the prompts to proceed with the update process.

Depending on your operating system, you might need to source your shell configuration file to apply the changes:

- **For Linux users** (Modify accordingly):

  ```sh
  printf "\n# Sourcing custom aliases\nalias update='sh ~/update.sh'" >>"${HOME}/.bashrc"
  source ~/.bashrc
  update
  ```

Once you've completed these steps, you'll have access to a streamlined update process for your Linux system. Enjoy the convenience of keeping your system up-to-date with ease! 🐧✨

### Configuration

- **Package Manager Selection**: Modify the script to specify your preferred package manager if it differs from the default.
- **Backup Options**: Enable or disable the backup functionality according to your preference.
- **Update Frequency**: Set up a cron job or scheduler to automate periodic updates if desired.

### Contributions

Contributions to this project are welcome! Whether you're suggesting new features, reporting bugs, or submitting pull requests, your input is valuable in improving this script for the Linux community.

### Disclaimer

While this script aims to simplify the update process and enhance system security, it is provided as-is, without any warranties. Use it at your own risk, and always review the script contents before execution to ensure it meets your requirements and does not pose any security risks.

### License

This script is licensed under the [Apache License 2.0](LICENSE), granting you the freedom to use, modify, and distribute it as you see fit.

### Support

For questions, feedback, or support, please open an issue on GitHub or reach out to the maintainers listed in the repository.

### Acknowledgments

Special thanks to the open-source community for their contributions, feedback, and ongoing support in improving this script.

---

Feel free to use, modify, and distribute this script to streamline the update process on your Linux system. If you have any questions or suggestions, don't hesitate to reach out or submit a pull request. Happy updating! 🐧🚀

## Updates

Currently including:

- 🐧 Linux Package Update (`apt/dnf/yum/pacman`)
- 🧑‍💻 VS Code Extensions (`code`)
- 📦 Node Package Manager (`npm`)
- 💎 RubyGems (`gem`)
- 🧶 Yarn (`yarn`)
- 🐍 Python3 (`pip3`)
