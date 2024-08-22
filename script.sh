#!/bin/bash

alias please="sudo"  # https://twitter.com/ctrlshifti/status/1160812366293901314

# Git related

# aliases so i don't have to type full word
alias gi="git"
alias g="git"
alias gt="git"


# submodule update
function gsu(){
    echo "running git submodule update --init --recursive"
    git submodule update --init --recursive
}

# git checkout master
function gcoma(){
    echo "running git checkout master || git checkout main"
    git checkout master || git checkout main
}

# git checkout {any-branch}
function gco(){
    if [[ $1 == "ma" ]] || [[ $1 == "" ]]; then
        gcoma
    else
        echo "running git checkout $1"
        git checkout $1
    fi
}

# aliases
alias gico='gco'
alias gicoma='gcoma'


# git reset hard (optionally can pass commit hash)
function gre(){
    echo "running git reset --hard $1"
    git reset --hard $1
}

# git push 
function gpsh(){
    echo "running git push -u origin HEAD"
    git push -u origin HEAD
}

# git add + commit + push
function acp(){
    echo "running git add -A; git commit -m '$*'; git push"
    git add -A; git commit -m "$*"; git push
}

# git push force
function gpf(){
    echo "running git push -f"
    git push -f
} 

# delete all branches except master
function deleteAllBranches(){
    echo "Deleting all branches except master and main"
    git branch | grep -v "master" | grep -v "main" | xargs git branch -D 
}


# This one is my favorite
# It checks out into a branch, pushes current changes and raises a pull request in github! 
# pull request url is copied in clipboard too! 
# need to install hub (hub.github.com) to make it work
prthis() {
    local message="$*"
    local branch_name=$(sed -e 's/ /-/g' <<< "$message")
    
    git checkout -b "$branch_name"
    acp "$message"

    local git_root=$(git rev-parse --show-toplevel)
    local pr_template_content=$(get_pr_template_content "$git_root")

    hub_create_pr "$message" "$pr_template_content"
}

# Function to find and retrieve the content of the PR template
get_pr_template_content() {
    local git_root="$1"

    # List of possible template locations
    local templates=(
        "$git_root/pull_request_template.md"
        "$git_root/PULL_REQUEST_TEMPLATE.md"
        "$git_root/.github/pull_request_template.md"
        "$git_root/.github/PULL_REQUEST_TEMPLATE.md"
    )

    for template in "${templates[@]}"; do
        if [[ -f "$template" ]]; then
            cat "$template"
            return
        fi
    done
}

hub_create_pr() {
    local message="$1"
    local pr_template_content="$2"

    if hub pull-request --push --browse --copy --draft --message "$message

$pr_template_content"; then
        echo "Draft PR created successfully."
    else
        echo "Failed to create a draft PR. Trying to create a regular PR..."
        hub pull-request --push --browse --copy --message "$message

$pr_template_content" || echo "Failed to create a regular PR as well."
    fi
}