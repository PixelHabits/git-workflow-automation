#!/bin/bash

# Utility functions for response validation
is_yes() { [[ "$1" =~ ^[Yy]([Ee][Ss])?$ ]]; }
is_no() { [[ "$1" =~ ^[Nn]o?$ ]]; }

current_dir_name="" # Initialize an empty string to hold the current directory
parent_dir_name="" # Initialize an empty string to hold the parent directory
repo_url="" # Initialize an empty string to hold the repository URL

# Always executed: Confirms the current directory
confirm_directory() {
    current_dir_name=$(basename "$PWD")
    parent_dir_name=$(basename "$(dirname "$PWD")")
    read -r -p "Is this the correct directory? (.../$parent_dir_name/$current_dir_name) (Yes/No): " response
    if is_no "$response"; then
        echo "Please navigate to the correct directory and restart the script."
        exit 1
    fi
}

# Downloads a project based on user preference
download_project() {
    echo "-----------------------------------"
    read -r -p "Do you need to download a project? (Yes/No): " need_download
    if is_yes "$need_download"; then
        echo
        read -r -p "Would you like to use 'tiged' or 'clone' to download the project? (tiged/clone): " download_method
        case $download_method in
            tiged) download_with_tiged ;;
            clone) download_with_clone ;;
            *) echo "Invalid option selected. Exiting script."; exit 1 ;;
        esac
    else
        echo "Okay, skipping project download."
        echo "-----------------------------------"
    fi
}

# Downloads a project using Tiged
download_with_tiged() {
    echo "-----------------------------------"
    read -r -p "Please enter the full 'npx tiged' command to download the project: " tig_command
    echo
    echo "Thanks, I'm about to download the project."
    echo
    confirm_directory
    eval "$tig_command"  # Using eval to execute the command as it's entered
    
    # Extracting the intended directory name from the tig_command
    local intended_dir
    intended_dir="$(echo "$tig_command" | awk '{print $NF}')"
    cd "$intended_dir" || { echo "Failed to change directory to $intended_dir. Does it exist?"; exit 1; }
    current_dir_name=$(basename "$PWD")
    parent_dir_name=$(basename "$(dirname "$PWD")")
    echo
    echo "Repository downloaded and I've changed the current directory to the project location."
    echo "-----------------------------------"
}

# Downloads a project using Git Clone
download_with_clone() {
    echo "-----------------------------------"
    read -r -p "Please enter the Git repository URL to clone: " git_clone_url
    echo "Thanks, I'm about to download the project."
    confirm_directory

    # Simplified clone process with immediate directory change
    local repo_name
    git clone "$git_clone_url" && repo_name=$(basename -s .git "$git_clone_url")

    cd "$repo_name" || { echo "Failed to change directory to $repo_name. Does it exist?"; exit 1; }
    current_dir_name=$(basename "$PWD")
    parent_dir_name=$(basename "$(dirname "$PWD")")
    echo
    echo "Repository downloaded and I've changed the current directory to the project location."
    echo "-----------------------------------"
}

# Creates a new GitHub repository
create_repo() {
    echo "-----------------------------------"
    read -r -p "Do you need to create a GitHub repository? (Yes/No): " need_repo
    echo
    if is_yes "$need_repo"; then
        confirm_directory
        local repo_name
        repo_name=$(basename "$PWD")
        current_dir_name=$(basename "$PWD")
        echo "Current directory name is '$current_dir_name'."
        echo "Creating a private GitHub repository named '$current_dir_name'."
        repo_url=$(gh repo create "$current_dir_name" --private --confirm -y 2>&1 | grep "https://")
        if [[ -z $repo_url ]]; then
            echo "Error creating GitHub repository. Please check if you're logged in with 'gh auth login'"
            exit 1
        fi
        echo "GitHub repository created with URL: $repo_url"
        echo "-----------------------------------"
    else
        echo "Okay, skipping repo creation."
        echo "-----------------------------------"
    fi
}

# Handles .gitignore
handle_gitignore() {
    echo "-----------------------------------"
    local missing_entries=()

    if [ -f ".gitignore" ]; then
        echo ".gitignore file already present."


        grep -qx "node_modules/" .gitignore || missing_entries+=("node_modules/")
        grep -qx ".env" .gitignore || missing_entries+=(".env")


        if [ ${#missing_entries[@]} -ne 0 ]; then
            for entry in "${missing_entries[@]}"; do
                echo "$entry" >> .gitignore
                echo "$entry added to .gitignore."
            done
        else
            echo "node_modules and .env are already in .gitignore."
        fi
    else
        echo "No .gitignore file found. I've printed the contents of the directory for you to check below:"
        echo
        ls -a
        echo
        read -r -p "Would you like to add a .gitignore file? (Yes/No): " add_gitignore
        if is_yes "$add_gitignore"; then
            echo "node_modules" > .gitignore
            echo ".env" >> .gitignore
            echo ".gitignore file created with node_modules and .env added."
        else
            echo "Skipping .gitignore file creation."
        fi
    fi
    echo "-----------------------------------"
}

# Installs node_modules
install_node_modules() {
    echo "-----------------------------------"
    local initial_dir
    initial_dir=$(pwd)  # Store the initial directory to return later
    local found_package_json=false

    # Check if package.json exists in the current directory
    if [ -f "${initial_dir}/package.json" ]; then
        echo "Found package.json in the current directory."
        found_package_json=true
        if [ -d "${initial_dir}/node_modules" ]; then
            echo "The 'node_modules' directory already exists in the current directory. Skipping installation."
        else
            read -r -p "The 'node_modules' directory does not exist in the current directory. Would you like to install node_modules? (Yes/No): " install_node
            if is_yes "$install_node"; then
                npm install
                echo "node_modules installed in the current directory."
            else
                echo "Skipping node_modules installation in the current directory."
            fi
        fi
    else
        # Find all directories containing a package.json file
        for dir in */ ; do
            if [ -f "${dir}package.json" ]; then
                echo "Found package.json in ${dir}"
                found_package_json=true
                cd "$dir" || continue  # Change to the directory or skip if not accessible

                if [ -d "node_modules" ]; then
                    echo "The 'node_modules' directory already exists in ${dir}. Skipping installation."
                else
                    read -r -p "The 'node_modules' directory does not exist in ${dir}. Would you like to install node_modules? (Yes/No): " install_node
                    if is_yes "$install_node"; then
                        npm install
                        echo "node_modules installed in ${dir}."
                    else
                        echo "Skipping node_modules installation in ${dir}."
                    fi
                fi

                cd "$initial_dir" || { echo "Failed to change directory to $initial_dir. Does it exist?"; exit 1; } # Return to the original directory
            fi
        done
    fi

    if [ "$found_package_json" = false ]; then
        echo "No package.json found in any directory."
    fi

    echo "-----------------------------------"
}

# Initializes Git
initialize_git() {
    echo "-----------------------------------"
    if [ -d ".git" ]; then
        echo "Git repository already initialized."
    else
        read -r -p "No Git repository found in the current directory. Would you like to initialize one? (Yes/No): " response
        if is_yes "$response"; then
            if git init; then
                echo "Git repository initialized."
            else
            echo "Failed to initialize Git repository."
            exit 1
            fi
        else
            echo "Git repository initialization skipped."
        fi
    fi
    echo "-----------------------------------"

}

# Stages and commits changes
stage_and_commit() {
    echo "-----------------------------------"
    echo "Here is the current git status:"
    echo
    git status
    echo 
    echo
    read -r -p "Are you ready to add files to staging? (Yes/No): " ready_to_add
    echo
    echo
    if is_yes "$ready_to_add"; then
        git add . && echo "Added all files to staging."
        echo "-----------------------------------"
    else
        echo "Skipping adding files to staging."
        echo "-----------------------------------"
        return
    fi
    echo "-----------------------------------"
    read -r -p "Are you ready to commit the changes? (Yes/No): " ready_to_commit
    echo
    if is_yes "$ready_to_commit"; then
        read -r -p "Is the commit message 'Initial Commit'? (Yes/No - Can be entered in the next step): " initial_commit
        echo
        if is_yes "$initial_commit"; then
            git commit -m "Initial Commit" || { echo "Commit failed."; exit 1; }
            echo
            echo
            echo "Okay, changes committed with the message: 'Initial Commit'"
            echo
            echo "-----------------------------------"
        else
            read -r -p "Enter your commit message: " commit_message
            git commit -m "$commit_message" || { echo "Commit failed."; exit 1; }
            echo
            echo
            echo "Okay, changes committed with message: '$commit_message'"
            echo
            echo "-----------------------------------"
        fi
        echo "Now that we've done a commit here is your updated status and last log entry:"
        echo
        echo "Git Status:"
        git status
        echo
        echo "Git Log Entry:"
        git log --oneline --graph --decorate --all
    else
    echo "Skipping commit."
    fi
    echo "-----------------------------------"
}

# Pushes to GitHub
push_to_github() {
    echo "-----------------------------------"
    read -r -p "Push changes to GitHub? (Yes/No): " push
        echo
        if is_yes "$push"; then
            echo
            echo "Git Status:"
            git status
            echo
            read -r -p "Does everything above look good, I'm about to try pushing to the GitHub Repo? (Yes/No): " looks_good
            if is_yes "$looks_good"; then
            echo
                if ! git remote get-url origin &> /dev/null; then
                    # This condition now implies either a new project or a cloned repo without an origin
                    if [ -n "$repo_url" ]; then
                        git remote add origin "$repo_url"
                        echo "Remote origin set to created repository URL."
                    else
                        read -r -p "Enter remote origin URL: " remote_origin_url
                        git remote add origin "$remote_origin_url" && echo "Remote origin added."
                        git remote -v
                    fi
                else
                    # Remote origin exists, print it and ask the user if they want to change it
                    existing_origin_url=$(git remote get-url origin)
                    echo "The existing remote origin URL is: $existing_origin_url"
                    read -r -p "Would you like to keep the existing remote origin? (Yes/No): " keep_origin
                    if is_no "$keep_origin"; then
                        read -r -p "Enter new remote origin URL: " new_origin_url
                        git remote set-url origin "$new_origin_url"
                        echo "Remote origin has been updated to $new_origin_url."
                    else
                        echo "Keeping the existing remote origin: $existing_origin_url."
                    fi
                fi
                echo
                echo "Pushing to GitHub"
                echo
                git push -u origin main || { echo "Push failed."; exit 1; }
                echo
                echo
                echo "All done, check the repo!"
                echo "-----------------------------------"
                echo
                git remote -v
                echo
            else
                echo
                echo "Review your changes and restart script."
            fi
        else
            echo
            echo "Review your changes and restart script."
            echo "-----------------------------------"
        fi
}

# Presents the capabilities and asks for a starting step
select_starting_step() {
    echo "Starting Git workflow automation..."
    echo
    echo "These are the actions I am capable of performing:"
    echo
    echo "1. Downloading a project"
    echo "2. Creating a new GitHub repository"
    echo "3. Handling .gitignore"
    echo "4. Installing node_modules"
    echo "5. Initializing Git"
    echo "6. Staging and committing changes"
    echo "7. Pushing to GitHub"
    echo
    echo
    echo "Enter a step to start at, or press the Enter key to begin from the start:"
    read -r -p "" starting_step
    if [ -z "$starting_step" ]; then
        starting_step=1  # Default to 1 if Enter is pressed
    fi
    echo "-----------------------------------"
}

# Main function to orchestrate the script
main() {
    echo "-----------------------------------"

    select_starting_step

    # Ensure the selected step is within the valid range, including Enter for start from 1
    if [ "$starting_step" -lt 1 ] || [ "$starting_step" -gt 7 ]; then
        echo "Invalid step selected. Please select a step between 1 and 7, or press Enter to start from the beginning."
        exit 1
    fi

    # Sequentially execute actions based on the starting step
    for (( step=starting_step; step<=7; step++ )); do
        case $step in
            1) download_project ;;
            2) create_repo ;;
            3) handle_gitignore ;;
            4) install_node_modules ;;
            5) initialize_git ;;
            6) stage_and_commit ;;
            7) push_to_github ;;
            *) echo "An unexpected error occurred."; exit 1 ;;
        esac
    done
    echo
    echo "***********************************"
    echo
    echo "Workflow complete. Thanks for using Git Workflow Automation!"
    echo
}

# Execute the main function
main
