load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
load(":providers.bzl", "PRISMA_BIN_ATTR", "PRISMA_DEFAULT_ENTRY_POINT", "PRISMA_SCHEMA_ATTR")

_COMMON_ATTRS = {
    "schema": PRISMA_SCHEMA_ATTR,
    "bin": PRISMA_BIN_ATTR,
}

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

lift_save = rule(
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

def _find_migrations_dir_by_lockfile(files):
    for file in files:
        if file.extension == "lock":
            return file.dirname

    fail("No lockfile was found, thus the migrations directory could not be found")

def _lift_up_impl(ctx):
    migrations_dir = _find_migrations_dir_by_lockfile(ctx.files.migrations)

    # {bin} lift save --schema {schema} --migrations {migrations} --name {name}
    #    ctx.actions.write(
    #        output = ctx.outputs.launcher,
    #        content = """
    #{bin} lift up --schema {schema} --migrations {migrations}
    #        """.format(
    #            bin = ctx.executable.bin.short_path,
    #            schema = ctx.file.schema.path,
    #            migrations = migrations_dir,
    #        ),
    #        is_executable = True,
    #    )
    #

    ctx.actions.run_shell(
        outputs = [ctx.outputs.stamp],
        tools = [ctx.executable.bin],
        use_default_shell_env = True,
        inputs = [ctx.file.schema] + ctx.files.migrations,
        command = """
{bin} lift up --schema {schema} --migrations {migrations}
echo $(date '+%Y-%m-%d %H:%M:%S') >> {stamp}
        """.format(
            bin = ctx.executable.bin.path,
            schema = ctx.file.schema.path,
            migrations = migrations_dir,
            stamp = ctx.outputs.stamp.path,
        ),
    )

    return [DefaultInfo(files = depset([ctx.outputs.stamp]))]

#    return [DefaultInfo(
#        files = depset([ctx.outputs.launcher]),
#        executable = ctx.outputs.launcher,
#        runfiles = ctx.runfiles(
#            # transitive_files = depset(transitive = [ctx.attr.bin[DefaultInfo].default_runfiles]),
#            files = ctx.files.migrations + [ctx.file.schema, ctx.executable.bin],
#            collect_data = True,
#            collect_default = True,
#        ),
#    )]

lift_up = rule(
    implementation = _lift_up_impl,
    # executable = True,
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
        #        "_runfiles": attr.label(
        #            default = Label("@bazel_tools//tools/bash/runfiles"),
        #        ),
    }),
    outputs = {
        "stamp": "STAMP",
    },
    #    outputs = {
    #        "launcher": "%{name}_launcher.sh",
    #    },
)
