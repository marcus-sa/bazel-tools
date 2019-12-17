load(":providers.bzl", "PrismaDataSource")

def _transform_url(ctx):
    url = ctx.expand_make_variables("url", ctx.attr.url, {})
    return url if url.startswith('env("') and url.endswith('")') else '"%s"' % url

def _prisma_datasource_impl(ctx):
    url = _transform_url(ctx)

    datasource = """
datasource %s {
  provider = "%s"
  url = %s
    """ % (
        ctx.attr.provider,
        ctx.attr.provider,
        url,
    )

    datasource = datasource.strip()

    datasource += """
}
    """

    return [PrismaDataSource(datasource = datasource.strip())]

prisma_datasource = rule(
    implementation = _prisma_datasource_impl,
    attrs = {
        "provider": attr.string(
            values = [
                "postgresql",
                "mysql",
                "sqlite",
            ],
            mandatory = True,
        ),
        "url": attr.string(
            mandatory = True,
        ),
    },
)
