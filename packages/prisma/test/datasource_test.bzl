load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//packages/prisma/src:datasource.bzl", "prisma_datasource")
load("//packages/prisma/src:providers.bzl", "PrismaDataSource")

def _datasource_provider_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)

    asserts.equals(
        env,
        """
datasource postgresql {
  provider = "postgresql"
  url = env("PRISMA_POSTGRES_URL")
  enabled = true
}
        """.strip(),
        target_under_test[PrismaDataSource].datasource,
    )

    return analysistest.end(env)

datasource_provider_contents_test = analysistest.make(_datasource_provider_contents_test_impl)

def _datasource_test_provider_contents():
    prisma_datasource(
        name = "datasource_provider_contents_subject",
        url = 'env("PRISMA_POSTGRES_URL")',
        provider = "postgresql",
        tags = ["manual"],
    )

    datasource_provider_contents_test(
        name = "datasource_provider_contents_test",
        target_under_test = ":datasource_provider_contents_subject",
    )

def prisma_datasource_test_suite(name, **kwargs):
    _datasource_test_provider_contents()

    native.test_suite(
        name = name,
        tests = [
            ":datasource_provider_contents_test",
        ],
        **kwargs
    )
