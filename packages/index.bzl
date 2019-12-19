"""Index file for packages.
"""

# packages that have nested workspaces in `src` folder
NESTED_PACKAGES = [
    "prisma",
    "graphql_codegen",
]

NPM_PACKAGES = ["@bazel-tools/%s" % pkg.replace("_", "-") for pkg in NESTED_PACKAGES]
