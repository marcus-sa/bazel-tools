load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")

def _grapql_codegen_impl(ctx):
    config_file = ctx.actions.declare_file(ctx.label.name + "_config.yml")

    if not ctx.attr.schema_url and not ctx.attr.schemas:
        fail("You must provide either `schema_url` or `schemas`")

    if ctx.attr.schema_url:
        url = ctx.expand_make_variables("url", ctx.attr.url, {})
        config_content = "schema: %s" % url
    else:
        config_content = "schema:\n- %s" % "\n- ".join([
            s.path
            for s in ctx.files.schemas
        ])

    config_content += """
overwrite: true
documents:
- {documents}
generates:
  {output}:
    plugins:
      - {plugins}
    """.format(
        documents = "\n- ".join(
            [d.path for d in ctx.files.documents],
        ),
        output = ctx.outputs.output.path,
        plugins = "\n      - ".join(ctx.attr.plugins),
    )

    #    if ctx.attr.hooks:
    #        config_content += "\nhooks:"
    #
    #        for hook_name, hook_cmds in ctx.attr.hooks.items():
    #            config_content += "\n  %s:" % hook_name
    #
    #            for hook_cmd in hook_cmds:
    #                config_content += "\n    - %s" % hook_cmd

    ctx.actions.write(
        output = config_file,
        content = config_content,
    )

    args = ctx.actions.args()
    args.add_all(["-c", config_file])

    ctx.actions.run(
        outputs = [ctx.outputs.output],
        inputs = [config_file] + ctx.files.schemas + ctx.files.documents,
        executable = ctx.executable.generator,
        use_default_shell_env = True,
        arguments = [args],
    )

    return [DefaultInfo(files = depset([ctx.outputs.output]))]

_graphql_codegen = rule(
    implementation = _grapql_codegen_impl,
    attrs = {
        "documents": attr.label_list(
            doc = "List of GraphQL documents to generate code for",
            allow_files = [".graphql"],
            mandatory = True,
        ),
        "schema_url": attr.string(),
        "schemas": attr.label_list(
            allow_files = [".graphql", ".js", ".ts"],
        ),
        "output": attr.output(),
        "plugins": attr.string_list(mandatory = True),
        # TODO: Not supported yet!
        # Should be a list of graphql_codegen_hooks which outputs executables
        # "hooks": attr.string_list_dict(),
        "generator": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
)

def graphql_codegen(
        name,
        deps = [],
        entry_point = "@npm//:node_modules/@graphql-codegen/cli/bin.js",
        **kwargs):
    nodejs_binary(
        name = "%s_bin" % name,
        entry_point = entry_point,
        install_source_map_support = False,
        data = deps + [
            "@npm//@graphql-codegen/cli",
            "@npm//json-to-pretty-yaml",
            "@npm//listr-update-renderer",
        ],
        visibility = ["//visibility:private"],
    )

    _graphql_codegen(
        name = name,
        generator = ":%s_bin" % name,
        **kwargs
    )
