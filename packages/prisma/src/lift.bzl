load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
load(":providers.bzl", "PRISMA_BIN_ATTR", "PRISMA_DEFAULT_ENTRY_POINT", "PRISMA_SCHEMA_ATTR")

_COMMON_ATTRS = {
    "schema": PRISMA_SCHEMA_ATTR,
    "bin": PRISMA_BIN_ATTR,
}

def _lift_impl(ctx):
    ""

lift = rule(
    implementation = _lift_impl,
    attrs = {
        # Will be set by lift macros
        "command": attr.string(
            values = [
                "up",
                "save",
                "down",
            ],
            mandatory = True,
        ),
        "migration_name": attr.string(
            doc = "Only mandatory when saving a migration",
        ),
        # "migrations":
        "schema": PRISMA_SCHEMA_ATTR,
        "bin": PRISMA_BIN_ATTR,
    },
)

def _lift_save_impl(ctx):
    migrations_dir = ctx.expand_make_variables("migrations_dir", ctx.attr.migrations_dir, {})
    migration_name = ctx.expand_make_variables("migration_name", ctx.attr.migration_name, {})

    steps = ctx.outputs.steps
    readme = ctx.outputs.readme
    schema = ctx.outputs.schema
    outputs = [steps, readme, schema]

    ctx.actions.run_shell(
        outputs = outputs,
        tools = [ctx.executable.bin],
        use_default_shell_env = True,
        inputs = [ctx.file.schema],
        command = """
set -e

{bin} lift save --schema {schema} --migrations {migrations} --name {name}

cp {migrations}/{name}/steps.json {steps_output}
cp {migrations}/{name}/README.md {readme_output}
cp {migrations}/{name}/schema.prisma {schema_output}
        """.format(
            bin = ctx.executable.bin.path,
            schema = ctx.file.schema.path,
            name = migration_name,
            migrations = migrations_dir,
            schema_output = schema.path,
            steps_output = steps.path,
            readme_output = readme.path,
        ),
    )

    return [DefaultInfo(files = depset([steps, readme, schema]))]

_lift_save = rule(
    implementation = _lift_save_impl,
    attrs = dict(_COMMON_ATTRS, **{
        "migrations_dir": attr.string(
            doc = "Absolute path of where to save migration, allows make variables",
            mandatory = True,
        ),
        "migration_name": attr.string(
            doc = "Name of migration, allows make variables",
        ),
    }),
    # Will be copied into dist bin as well as into chosen migrations directory
    outputs = {
        "steps": "%{name}/migrations/steps.json",
        "readme": "%{name}/migrations/README.md",
        "schema": "%{name}/migrations/schema.prisma",
    },
)

def lift_save(name, **kwargs):
    nodejs_binary(
        name = "%s_bin" % name,
        data = ["@npm//prisma2"],
        entry_point = PRISMA_DEFAULT_ENTRY_POINT,
        visibility = ["//visibility:private"],
    )

    _lift_save(
        name = name,
        bin = ":%s_bin" % name,
        **kwargs
    )

#def lift(schema, cmd, **kwargs):
#    nodejs_binary(
#        data = ["@npm//prisma2", schema],
#        entry_point = PRISMA_DEFAULT_ENTRY_POINT,
#        templated_args = [
#            "lift",
#            cmd,
#            "--schema",
#            "$(location %s)" % schema,
#        ],
#        **kwargs
#    )

def _lift_up_impl(ctx):
    ""

lift_up = rule(
    implementation = _lift_up_impl,
    attrs = dict(_COMMON_ATTRS, **{
        "migrations": attr.label_list(
            allow_files = [
                "lift.lock",
                "schema.prisma",
                "steps.json",
                "README.md",
            ],
            mandatory = True,
            allow_empty = False,
        ),
    }),
)

def lift_down(schema, **kwargs):
    lift(
        schema = schema,
        command = "down",
        **kwargs
    )
