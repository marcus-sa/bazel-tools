load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
load(
    ":providers.bzl",
    "PRISMA_BIN_ATTR",
    "PRISMA_DEFAULT_ENTRY_POINT",
    "PRISMA_SCHEMA_ATTR",
    "PrismaGenerator",
)

def _declare_outputs(ctx):
    outputs = ctx.attr.schema[PrismaGenerator].outputs
    return [ctx.actions.declare_file(output) for output in outputs]

def _photon_generate_impl(ctx):
    outputs = _declare_outputs(ctx)
    schema = ctx.file.schema

    args = ctx.actions.args()
    args.add("generate")
    args.add_all(["--schema", schema])

    ctx.actions.run(
        outputs = outputs,
        inputs = [schema],
        executable = ctx.executable.bin,
        use_default_shell_env = True,
        arguments = [args],
    )

    return [DefaultInfo(files = depset(outputs))]

photon_generate = rule(
    implementation = _photon_generate_impl,
    attrs = {
        "schema": PRISMA_SCHEMA_ATTR,
        "bin": PRISMA_BIN_ATTR,
    },
)

def photon_generate_macro(name, schema, **kwargs):
    nodejs_binary(
        name = "%s_bin" % name,
        data = ["@npm//prisma2", "@npm//@prisma/photon"],
        entry_point = PRISMA_DEFAULT_ENTRY_POINT,
        visibility = ["//visibility:private"],
        **kwargs
    )

    photon_generate(
        name = name,
        bin = ":%s_bin" % name,
        schema = schema,
        **kwargs
    )
