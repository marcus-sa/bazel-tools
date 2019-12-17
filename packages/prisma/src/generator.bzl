load(":providers.bzl", "PrismaGenerator")
load(":outputs.bzl", "PHOTON_OUTPUTS")

def _collect_outputs(provider, output_dir):
    outputs = PHOTON_OUTPUTS[provider]
    return [output_dir + "/" + output for output in outputs]

def _prisma_generator_impl(ctx):
    provider = ctx.attr.provider
    output_dir = ctx.attr.output
    outputs = _collect_outputs(provider, output_dir)

    data = """
generator %s {
  provider = "%s"
  output = "%s"
    """ % (
        provider,
        provider,
        output_dir,
    )

    data = data.strip()

    # TODO: Use Bazel builtin tools for this
    #    if len(ctx.attr.binary_targets) > 0:
    #        data += """
    #  binaryTargets = ["{TMPL_binary_targets}"]
    #        """.format(
    #            TMPL_binary_targets = '", "'.join([
    #                bt
    #                for bt in ctx.attr.binary_targets
    #            ]),
    #        )
    #        data = data.strip()

    data += """
}
    """

    return [PrismaGenerator(
        data = data.strip(),
        outputs = outputs,
        # binary =
    )]

prisma_generator = rule(
    implementation = _prisma_generator_impl,
    attrs = {
        "provider": attr.string(
            values = ["photonjs"],
            default = "photonjs",
        ),
        "output": attr.string(
            # output
            mandatory = True,
        ),
        #        "binary": attr.string(
        #            values = [
        #                "",
        #            ],
        #            mandatory = True,
        #        ),
        #        "binary_targets": attr.string_list(
        #            # allow_empty = False,
        #            # mandatory = False,
        #        ),
    },
)
