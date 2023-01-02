locals {
    env = split("/", path_relative_to_include())[0]
}