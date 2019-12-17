load(
    ":providers.bzl",
    "PrismaDataModel",
    "PrismaDataSource",
    "PrismaGenerator",
)

def _collect_generator(ctx):
    return ctx.attr.generator[PrismaGenerator]

def _collect_datasources(ctx):
    return [
        ds[PrismaDataSource].datasource
        for ds in ctx.attr.datasources
    ]

def _collect_datamodels(ctx):
    datamodels = []

    for _datamodels in ctx.attr.datamodels:
        datamodels += _datamodels[PrismaDataModel].datamodels

    return datamodels

def _prisma_schema_impl(ctx):
    datasources = _collect_datasources(ctx)
    datamodels = _collect_datamodels(ctx)
    generator = _collect_generator(ctx)
    schema = ctx.outputs.schema

    ctx.actions.run_shell(
        outputs = [schema],
        use_default_shell_env = True,
        inputs = datamodels,
        command = """
echo '{TMPL_datasources}\n' >> {TMPL_schema}
echo '{TMPL_generator}\n' >> {TMPL_schema}

for file in {TMPL_models}; do
  cat "$file" >> {TMPL_schema}
  echo '\n' >> {TMPL_schema}
done
        """.format(
            TMPL_schema = schema.path,
            TMPL_generator = generator.data,
            TMPL_datasources = " ".join(datasources),
            TMPL_models = " ".join([model.path for model in datamodels]),
        ),
    )

    return [
        PrismaGenerator(
            data = generator.data,
            outputs = generator.outputs,
        ),
        DefaultInfo(files = depset([schema])),
    ]

prisma_schema = rule(
    implementation = _prisma_schema_impl,
    attrs = {
        "datamodels": attr.label_list(
            doc = "prisma_datamodel targets to include",
            mandatory = True,
            allow_empty = False,
            providers = [PrismaDataModel],
            allow_files = False,
        ),
        "datasources": attr.label_list(
            doc = "prisma_datasource targets to include",
            mandatory = True,
            allow_empty = False,
            providers = [PrismaDataSource],
            allow_files = False,
        ),
        "generator": attr.label(
            doc = "prisma_generator target to include",
            mandatory = True,
            providers = [PrismaGenerator],
            allow_files = False,
        ),
    },
    outputs = {
        "schema": "%{name}.prisma",
    },
)
