load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

bzl_library(
    name = "bzl",
    srcs = glob(["*.bzl"]),
    deps = [
        "@npm_bazel_tools//tools:bzl",
    ],
)

stardoc(
    name = "docs",
    out = "index.md",
    input = "index.bzl",
    tags = ["fix-windows"],
    deps = [":bzl"],
)

filegroup(
    name = "package_contents",
    srcs = ["package.json"] + glob([
        "*.bzl",
        "patches/*.patch",
    ]),
)
