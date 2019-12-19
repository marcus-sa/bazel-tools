load("@npm_bazel_tools_eslint//eslint:index.bzl", "eslint_test")

def eslint(config, srcs, deps = [], **kwargs):
    data = deps + [
        config,
    ]

    args = [
        "-c",
        "$(location %s)" % config,
    ] + ["$(locations %s)" % f for f in srcs]

    eslint_test(
        data = data + srcs,
        args = args,
        **kwargs
    )
