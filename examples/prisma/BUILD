load("@npm_bazel_typescript//:index.bzl", "ts_library")
load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
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
    # url = "$(datasource)",
    # HINT: cannot be used because environment is not inherited https://github.com/prisma/prisma2/issues/1053#issuecomment-567183500
    # Prisma requires the environment variable to be set at generation time instead of runtime
    # so when running the generator you can just set it as empty
    # --action_env PRISMA_POSTGRES_URL=
    url = 'env("PRISMA_POSTGRES_URL")',
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
    name = "prisma",
    srcs = ["index.ts"],
    deps = [":client"],
)

ts_library(
    name = "seed_lib",
    srcs = ["seed.ts"],
    deps = [":prisma"],
)

nodejs_binary(
    name = "seed",
    configuration_env_vars = [
        "PRISMA_POSTGRES_URL",
    ],
    data = [
        ":photonjs",
        ":seed_lib",
    ],
    entry_point = ":seed.ts",
)
