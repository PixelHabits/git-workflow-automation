# Git Workflow Automation Script

This Bash script streamlines the Git workflow for developers by automating several common tasks associated with setting up, maintaining, and pushing changes to a Git repository. It's designed to save time and reduce the manual steps required during project setup and version control management.

Fun Fact 😄

This very script was used to automate the setup of its own repository. It's a bit like sending a robot back in time to build itself. We've truly come full circle! 🤖🔄😂

## Prerequisites

Before you start, ensure you have the following prerequisites installed on your system:

- Git
- Node.js and npm (if your project requires them)
- GitHub CLI

### macOS Specific Requirements
- HomeBrew to install GitHub CLI
  
### Operating System Compatibility

This script is designed to run on Unix-like operating systems with native Bash support, such as Linux and macOS. Windows users can run the script through the Windows Subsystem for Linux (WSL)

## Features:

- **Directory Confirmation:** Prompts the user to confirm they're working in the correct directory before proceeding with any Git operations, enhancing safety and accuracy.
- **Project Download Option:** Offers the choice to download a project using either the `tiged` (npx tiged command) or `git clone` method, facilitating easy project setup from a remote repository.
- **Automatic Repository Creation:** Allows the creation of a new GitHub repository for the current directory. It initializes the repository as private by default, streamlining the process of going from a local project to a remote repository.
- **`.gitignore` File Management:** Checks for the existence of a `.gitignore` file and offers to create one if it's missing, with a default entry to ignore `node_modules`, helping maintain a clean repository.
- **Node Modules Installation:** Detects if the `node_modules` directory exists and offers to install dependencies using `npm install` if it doesn't, ensuring project dependencies are up to date.
- **Git Initialization Check:** Verifies if the current directory is already initialized as a Git repository, and initializes one if not, ensuring that version control is set up.
- **Staging and Committing Changes:** Prompts the user to stage all changes and commit them, with options for an "Initial Commit" message or a custom message, facilitating straightforward version control management.
- **Git Status and Log Overview:** After committing, displays the current Git status and a log of commits, providing a clear overview of the repository's state.
- **Remote Origin Management:** Checks if a remote origin is set and offers to add or change it, ensuring that the local repository is correctly linked to a remote one. This step includes pushing changes to the remote repository.
- **Push Validation:** Before pushing, confirms with the user that everything looks good, adding an extra layer of verification to prevent accidental pushes.
- **Script Exit Points:** Includes multiple exit points based on user decisions or if critical steps fail (e.g., directory change, Git repository initialization), ensuring that the script does not proceed without the required setup.

## Usage:

Ensure you have Git, npm (Node Package Manager), and the GitHub CLI installed on your system before using the script. If you haven't set up the alias `gitwf` for the script, please refer to the installation instructions provided with this project for details on how to do so. This alias allows for easy access and execution of the script from anywhere in your terminal.

To use the script, simply type `gitwf` or the alias you setup into your terminal and press Enter while in the directory you would like your project to be downloaded or the directory of the project you want to run the above-mentioned functions on. Follow the interactive prompts to navigate through various Git and project setup tasks, such as confirming the current directory, downloading a project, creating a repository, managing `.gitignore`, installing node modules, initializing Git, staging and committing changes, and managing remote origins.

This script is designed to improve the efficiency of Git workflows, making it easier for developers to manage their version control tasks and project setups this may not be a perfect fit for your use case, so if you have any suggestion for improvements feel free to submit a issue or pull request. I would to expand the functionality of this script.

## Installation

### Windows Subsystem for Linux (WSL)

#### Step 1: Install the GitHub CLI

First, install the GitHub CLI (`gh`) if it's not already installed on your machine. Execute the following commands in your terminal:

```sh
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

#### Step 2: Authenticate with GitHub

Authenticate with your GitHub account using `gh`:

```sh
gh auth login
```

Follow the prompts to select your preferred authentication method and set the default git protocol.

### macOS Instructions

#### Step 1: Install Homebrew (if not already installed)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Step 2: Install GitHub CLI

```sh
brew install gh
```

#### Step 3: Authenticate with GitHub

```sh
gh auth login
```

Follow the prompts to select your preferred authentication method and set the default git protocol.

### General Instructions for Both WSL and macOS

#### Step 3: Download the Script

Download `git_workflow.sh` to your machine. Place it in your home directory or one dedicated to scripts/utilities for easy access.

#### Step 4: Upgrade Permissions

Ensure the script is executable by updating its permissions:

```sh
chmod +x /path/to/git_workflow.sh
```

For example, if placed in home directory as suggested the command would be:

```sh
chmod +x git_workflow.sh
```

Replace `/path/to/git_workflow.sh` with the actual file path.

#### Step 5: Add an Alias for the Script

Add an alias to your terminal's profile file to easily access the script:

For Bash users:

```sh
echo "alias gitwf='bash /path/to/git_workflow.sh'" >> ~/.bashrc
source ~/.bashrc
```

For Zsh (macOS) users:

```sh
echo "alias gitwf='bash /path/to/git_workflow.sh'" >> ~/.zshrc
source ~/.zshrc
```

Replace `/path/to/git_workflow.sh` with the actual path to the script.

## Contributing

If you'd like to contribute to the development of the script, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/AmazingFeature`).
3. Make your changes and commit them (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html) for details. The GNU GPLv3 is a free, copyleft license for software and other kinds of works, offering the freedom to use, modify, and distribute, ensuring that all modifications and derived works are also available under the same license.

## Contact

[PixelHabits](https://github.com/PixelHabits)

Project Link: [https://github.com/PixelHabits/git-workflow-automation](https://github.com/PixelHabits/git-workflow-automation)
