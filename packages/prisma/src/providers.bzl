PrismaDataSource = provider(
    doc = "Collects files from prisma_datasource for use in downstream prisma_generate and prisma_lift",
    fields = {
        "datasource": "",
    },
)

PrismaGenerator = provider(
    doc = "Collects files from prisma_generator for use in downstream prisma_generate and prisma_lift",
    fields = {
        "data": "",
        "outputs": "List of strings that will be used as the outputs of the generator",
    },
)

PrismaDataModel = provider(
    doc = "Collects files from prisma_datamodel for use in downstream prisma_generate and prisma_lift",
    fields = {
        "datamodels": "",
    },
)

PRISMA_DEFAULT_ENTRY_POINT = "@npm//:node_modules/prisma2/build/index.js"

PRISMA_BIN_ATTR = attr.label(
    executable = True,
    default = Label("@npm//prisma2/bin:prisma2"),
    cfg = "host",
)

PRISMA_SCHEMA_ATTR = attr.label(
    allow_single_file = [".prisma"],
    mandatory = True,
)
