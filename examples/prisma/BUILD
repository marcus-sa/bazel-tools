load("@npm_bazel_typescript//:index.bzl", "ts_library")
load("//tools:js_sources.bzl", "js_sources")
load(
    "//packages/prisma/src:index.bzl",
    "lift_save",
    "lift_up",
    "photon_generate",
    "prisma_datamodel",
    "prisma_datasource",
    "prisma_generator",
    "prisma_schema",
)

prisma_datasource(
    name = "postgres_datasource",
    provider = "postgresql",
    # --define datasource=postgres://prisma:prisma@localhost:5432/prisma
    url = "$(datasource)",
    # Prisma requires the environment variable to be set at generation time instead of runtime
    # so when running the generator you can just set it as empty
    # --action_env PRISMA_POSTGRES_URL=
    # url = 'env("PRISMA_POSTGRES_URL")',
)

prisma_generator(
    name = "photonjs_generator",
    output = "client",
    provider = "photonjs",
)

prisma_datamodel(
    name = "models",
    srcs = glob(["*.prisma"]),
)

prisma_schema(
    name = "schema",
    datamodels = [":models"],
    datasources = [":postgres_datasource"],
    generator = ":photonjs_generator",
)

lift_up(
    name = "migration_up",
    migrations = ["//examples/prisma/migrations"],
    schema = ":schema",
    tags = ["manual"],
)

lift_save(
    name = "migration_save",
    # --define name=initial
    migration_name = "$(name)",
    # --define directory=$(pwd)/examples/prisma/migrations
    migrations_dir = "$(directory)",
    #    migrations = glob(["migrations/**"]),
    schema = ":schema",
    tags = ["manual"],
)

photon_generate(
    name = "photonjs",
    schema = ":schema",
)

js_sources(
    name = "client",
    srcs = [":photonjs"],
)

ts_library(
    name = "example",
    srcs = ["index.ts"],
    deps = [":client"],
)
