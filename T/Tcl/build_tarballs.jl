# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Tcl"
version = v"8.6.11"

# Collection of sources required to build Tcl
sources = [
    ArchiveSource("https://downloads.sourceforge.net/sourceforge/tcl/tcl$(version)-src.tar.gz",
                  "8C0486668586672C5693D7D95817CB05A18C5ECCA2F40E2836B9578064088258"),
]

# Bash recipe for building across all platforms
script = raw"""
if [[ "${target}" == *-mingw* ]]; then
    cd $WORKSPACE/srcdir/tcl*/win/
    # `make install` calls `tclsh` on Windows
    apk add tcl
else
    cd $WORKSPACE/srcdir/tcl*/unix/
fi

FLAGS=()
if [[ "${target}" == x86_64-* ]]; then
    FLAGS+=(--enable-64bit)
fi
./configure --prefix=${prefix} --host=${target} "${FLAGS[@]}"
make -j${nproc}
make install
# Tk needs private headers
make install-private-headers

# Install license file
install_license $WORKSPACE/srcdir/tcl*/license.terms
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct(["libtcl8.6", "libtcl8", "tcl86"], :libtcl),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("Zlib_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

