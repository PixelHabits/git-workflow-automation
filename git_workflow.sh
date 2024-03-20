#!/bin/bash

# Function to check if the response is affirmative
is_yes() {
    [[ "$1" =~ ^[Yy][Ee]?[Ss]?$ ]]
}

# Function to check if the response is negative
is_no() {
    [[ "$1" =~ ^[Nn][Oo]?$ ]]
}

echo "Starting Git workflow automation..."
echo "-----------------------------------"

repo_url="" # Initialize an empty string to hold the repository URL

# Function to confirm current directory
confirm_directory() {
    local current_dir_name=$(basename "$PWD")
    local parent_dir_name=$(basename "$(dirname "$PWD")")
    local prompt_message="Are you in the correct directory? ($parent_dir_name/$current_dir_name) (Yes/No): "
    
    read -p "$prompt_message" confirm_dir
    if is_no "$confirm_dir"; then
        echo "Please navigate to the correct directory and restart the script."
        exit 1
    fi
}




# Always confirm directory at the beginning
confirm_directory

# Ask if need to download a project
read -p "Do you need to download a project? (Yes/No): " need_download
if is_yes "$need_download"; then
    echo "-----------------------------------"
    read -p "Would you like to use 'tiged' or 'clone' to download the project? (tiged/clone): " download_method

    if [[ "$download_method" == "tiged" ]]; then
        read -p "Please enter the full 'npx tiged' command to download the project: " tig_command
        eval $tig_command # Using eval to execute the command as it's entered
        # Assuming the last argument is the directory name, which might not always be correct
        dir_name=$(echo $tig_command | awk '{print $NF}')
        cd "$dir_name" || { echo "Failed to change directory to $dir_name. Does it exist?"; exit 1; }
    elif [[ "$download_method" == "clone" ]]; then
        read -p "Please enter the Git repository URL to clone: " git_clone_url
        repo_name=$(basename -s .git "$git_clone_url")
        git clone "$git_clone_url"
        cd "$repo_name" || { echo "Failed to change directory to $repo_name. Does it exist?"; exit 1; }
    else
        echo "Invalid option selected. Exiting script."
        exit 1
    fi
    echo "Repository downloaded and changed to directory."
    echo "-----------------------------------"
else
    echo "Okay, skipping project download."
    echo "-----------------------------------"
fi



# Ask if need to create a repo
read -p "Do you need to create a repo? (Yes/No): " need_repo
if is_yes "$need_repo"; then
    confirm_directory
    current_dir=${PWD##*/}
    echo "Current directory name is '$current_dir'."
    echo "Creating a private GitHub repository named '$current_dir'."
    repo_url=$(gh repo create "$current_dir" --private --confirm -y | grep "https://")
    echo "GitHub repository created with URL: $repo_url"
    echo "-----------------------------------"
else
    echo "Okay, skipping repo creation."
    echo "-----------------------------------"
    # Confirm current directory after potentially creating a repo
    confirm_directory
fi


# Check for .gitignore file
if [ ! -f .gitignore ]; then
    echo "No .gitignore file found. I've printed the contents of the directory below:"
    ls -a
    echo "-----------------------------------"
    read -p "Would you like to add a .gitignore file? (Yes/No): " add_gitignore
    if is_yes "$add_gitignore"; then
        echo "node_modules" > .gitignore
        echo ".gitignore file created and node_modules added."
    fi
    echo "-----------------------------------"
fi

# Ask if user wants to install node_modules
if [ -d "node_modules" ]; then
    echo "The 'node_modules' directory already exists. Skipping installation."
else
    read -p "The 'node_modules' directory does not exist. Would you like to install node_modules? (Yes/No): " install_node
    if is_yes "$install_node"; then
        npm install
        echo "node_modules installed."
    else
        echo "Skipping node_modules installation."
    fi
fi
echo "-----------------------------------"


# Checking if the repository has already been initialized
if [ -d ".git" ]; then
    echo "Git repository already initialized."
else
    git init || { echo "Failed to initialize Git repository."; exit 1; }
    echo "Git repository initialized."
fi
echo "-----------------------------------"

# Asking if the user is ready to add files to staging
read -p "Are you ready to add files to staging? (Yes/No): " ready_to_add
if is_yes "$ready_to_add"; then
    git add . && echo "Added all files to staging."
else
    echo "Skipping adding files to staging."
fi
echo "-----------------------------------"

# Asking if the user is ready to commit the changes & Commit changes with a message
if is_yes "$ready_to_add"; then # Proceed if the user was ready to add
    read -p "Are you ready to commit the changes? (Yes/No): " ready_to_commit
    if is_yes "$ready_to_commit"; then
        read -p "Is the commit message 'Initial Commit'? (Yes/No - Can be entered in the next step): " initial_commit
        if is_yes "$initial_commit"; then
            git commit -m "Initial Commit" || { echo "Commit failed."; exit 1; }
            echo "Changes committed with the message: 'Initial Commit'"
        else
            read -p "Enter your commit message: " commit_message
            git commit -m "$commit_message" || { echo "Commit failed."; exit 1; }
            echo "Changes committed with message: '$commit_message'"
        fi
    else
        echo "Skipping commit."
    fi
else
    echo "Cannot proceed to commit without adding files to staging."
fi
echo "-----------------------------------"

# Show git status and log
git status
echo "-----------------------------------"
git log --oneline --graph --decorate --all
echo "-----------------------------------"


# Confirm if everything looks good
read -p "Does everything above look good, I'm about to try pushing to the GitHub Repo? (Yes/No): " looks_good
if is_yes "$looks_good"; then
    echo "-----------------------------------"
    if ! git remote get-url origin &> /dev/null; then
        # This condition now implies either a new project or a cloned repo without an origin
        if [ -n "$repo_url" ]; then
            git remote add origin "$repo_url"
            echo "Remote origin set to created repository URL."
        else
            read -p "Enter remote origin URL: " remote_origin_url
            git remote add origin "$remote_origin_url" && echo "Remote origin added."
        fi
    else
        # Remote origin exists, print it and ask the user if they want to change it
        existing_origin_url=$(git remote get-url origin)
        echo "The existing remote origin URL is: $existing_origin_url"
        read -p "Would you like to keep the existing remote origin? (Yes/No): " keep_origin
        if is_no "$keep_origin"; then
            read -p "Enter new remote origin URL: " new_origin_url
            git remote set-url origin "$new_origin_url"
            echo "Remote origin has been updated to $new_origin_url."
        else
            echo "Keeping the existing remote origin: $existing_origin_url."
        fi
    fi
    echo "-----------------------------------"
    git remote -v
    echo "-----------------------------------"
    git push -u origin main || { echo "Push failed."; exit 1; }
    echo "All done, check the repo!"
else
    echo "Please review your changes before proceeding."
fi
echo "-----------------------------------"
echo "Workflow setup complete."
