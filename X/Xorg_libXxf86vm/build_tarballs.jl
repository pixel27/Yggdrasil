# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Xorg_libXxf86vm"
version = v"1.1.4"

# Collection of sources required to build libXxf86vm
sources = [
    ArchiveSource("https://www.x.org/archive/individual/lib/libXxf86vm-$(version).tar.bz2",
                  "afee27f93c5f31c0ad582852c0fb36d50e4de7cd585fcf655e278a633d85cd57"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libXxf86vm-*/
CPPFLAGS="-I${prefix}/include"
# When compiling for things like ppc64le, we need newer `config.sub` files
update_configure_scripts
./configure --prefix=${prefix} --host=${target} --enable-malloc0returnsnull=no
make -j${nproc}
make install
"""

# There's a problem on ppc64le that I don't understand yet, we'll tackle this when it's necessary
platforms = [p for p in supported_platforms() if p isa Union{Linux,FreeBSD} && arch(p) != :powerpc64le]

products = Product[
    LibraryProduct("libXxf86vm", :libXxf86vm),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    BuildDependency("Xorg_xorgproto_jll"),
    BuildDependency("Xorg_util_macros_jll"),
    Dependency("Xorg_libXext_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
