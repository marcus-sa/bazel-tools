workspace(
    name = "npm_bazel_tools",
    managed_directories = {"@npm": ["node_modules"]},
)

#
# Nested package worksapces required to build packages & reference rules
#

load("//packages:index.bzl", "NESTED_PACKAGES")

[local_repository(
    name = "npm_bazel_tools_%s" % name,
    path = "packages/%s/src" % name,
) for name in NESTED_PACKAGES]

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Fetch rules_nodejs so we can install our npm dependencies
http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "121f17d8b421ce72f3376431c3461cd66bfe14de49059edc7bb008d5aebd16be",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/2.3.1/rules_nodejs-2.3.1.tar.gz"],
)

# Setup the Node.js toolchain
load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

yarn_install(
    name = "npm",
    package_json = "//:package.json",
    quiet = False,
    yarn_lock = "//:yarn.lock",
)

# Install any Bazel rules which were extracted earlier by the yarn_install rule.
load("@npm//:install_bazel_dependencies.bzl", "install_bazel_dependencies")

install_bazel_dependencies()

# Needed for starlark unit testing
http_archive(
    name = "bazel_skylib",
    sha256 = "1dde365491125a3db70731e25658dfdd3bc5dbdfd11b840b3e987ecf043c7ca0",
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/0.9.0/bazel_skylib-0.9.0.tar.gz",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
