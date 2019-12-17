load("//tools/prisma:providers.bzl", "PrismaDataModel")

def _prisma_datamodel_impl(ctx):
    return [
        PrismaDataModel(datamodels = ctx.files.srcs),
        DefaultInfo(
            files = depset(ctx.files.srcs),
            runfiles = ctx.runfiles(files = ctx.files.srcs),
        ),
    ]

prisma_datamodel = rule(
    implementation = _prisma_datamodel_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".prisma"],
            allow_empty = False,
            mandatory = True,
        ),
    },
)
