#!/usr/bin/env bats

# Ensure script is run with sudo
@test "Check if script is run with sudo" {
    run bash update_all.sh
    [ "$status" -eq 1 ]
    [ "$output" = "Please run this script with sudo." ]
}

# Test update functions
@test "Test update Debian based" {
    run update_debian
    [ "$status" -eq 0 ]
    [ "$output" = *"Update completed."* ]
}

@test "Test update RPM based" {
    run update_rpm
    [ "$status" -eq 0 ]
    [ "$output" = *"Update completed."* ]
}

@test "Test update Pacman based" {
    run update_pacman
    [ "$status" -eq 0 ]
    [ "$output" = *"Update completed."* ]
}

# Test update_os function
@test "Test update_os function" {
    run update_os
    [ "$status" -eq 0 ]
    [ "$output" != *"Unsupported Linux distribution."* ]
}

# Test update functions for packages
@test "Test update vscode extensions" {
    run update_vscode_ext
    [ "$status" -eq 0 ]
    [ "$output" = *"Updating VSCode Extensions"* ]
}

@test "Test update gem packages" {
    run update_gem
    [ "$status" -eq 0 ]
    [ "$output" = *"Updating Gems"* ]
}

@test "Test update npm packages" {
    run update_npm
    [ "$status" -eq 0 ]
    [ "$output" = *"Updating Npm Packages"* ]
}

@test "Test update yarn packages" {
    run update_yarn
    [ "$status" -eq 0 ]
    [ "$output" = *"Updating Yarn Packages"* ]
}

@test "Test update pip3 packages" {
    run update_pip3
    [ "$status" -eq 0 ]
    [ "$output" = *"Updating Python 3.x pips"* ]
}

# Test update_all function
@test "Test update_all function" {
    run update_all
    [ "$status" -eq 0 ]
    [ "$output" != *"Internet Disabled!!!"* ]
}
