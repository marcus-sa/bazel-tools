load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load(":generator.bzl", "prisma_generator")
load(":providers.bzl", "PrismaGenerator")

def _generator_provider_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)

    asserts.equals(
        env,
        """
generator photonjs {
  provider = "photonjs"
  output = "generated"
  binaryTargets = ["native", "debian-openssl-1.0.x"]
}
        """.strip(),
        target_under_test[PrismaGenerator].generator,
    )

    return analysistest.end(env)

generator_provider_contents_test = analysistest.make(_generator_provider_contents_test_impl)

def _test_generator_provider_contents():
    prisma_generator(
        name = "generator_provider_contents_subject",
        output = "generated",
        provider = "photonjs",
        binary_targets = ["native", "debian-openssl-1.0.x"],
        tags = ["manual"],
    )

    generator_provider_contents_test(
        name = "generator_provider_contents_test",
        target_under_test = ":generator_provider_contents_subject",
    )

def prisma_generator_test_suite(name, **kwargs):
    _test_generator_provider_contents()

    native.test_suite(
        name = name,
        tests = [
            ":generator_provider_contents_test",
        ],
        **kwargs
    )
