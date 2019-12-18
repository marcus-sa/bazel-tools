load(":generator.bzl", _prisma_generator = "prisma_generator")
load(":datamodel.bzl", _prisma_datamodel = "prisma_datamodel")
load(":datasource.bzl", _prisma_datasource = "prisma_datasource")
load(":photon.bzl", _photon_generate_macro = "photon_generate_macro")
load(":schema.bzl", _prisma_schema = "prisma_schema")
load(
    ":lift.bzl",
    #_lift_down = "lift_down",
    _lift_save = "lift_save",
    _lift_up = "lift_up",
)

prisma_generator = _prisma_generator
prisma_datamodel = _prisma_datamodel
prisma_datasource = _prisma_datasource
prisma_schema = _prisma_schema
photon_generate = _photon_generate_macro
lift_up = _lift_up

# lift_down = _lift_down
lift_save = _lift_save
