# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="C++ library for real-time resampling of audio signals"
HOMEPAGE="http://kokkinizita.linuxaudio.org/linuxaudio/"
SRC_URI="http://kokkinizita.linuxaudio.org/linuxaudio/downloads/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0/1"
KEYWORDS="amd64 arm arm64 ~ia64 ~loong ~mips ppc ppc64 ~riscv sparc ~x86"
IUSE="cpu_flags_x86_sse2 tools"

RDEPEND="tools? ( media-libs/libsndfile )"
DEPEND="${RDEPEND}"

HTML_DOCS="docs/."

PATCHES=( "${FILESDIR}"/${PN}-1.10.1-makefile.patch )

src_compile() {
	tc-export CXX
	# Code paths that uses intrinsics are not properly guarded by symbol checks
	if use cpu_flags_x86_sse2 ; then
		if tc-cpp-is-true "defined(__SSE2__)" ${CFLAGS} ${CXXFLAGS} ; then
			append-cppflags "-DENABLE_SSE2"
		else
			ewarn "SSE2 support has been disabled automatically because the"
			ewarn "compiler does not support corresponding intrinsics"
		fi
	fi

	emake -C source
	if use tools; then
		emake -C apps
	fi
}

src_install() {
	emake -C source DESTDIR="${D}" PREFIX="${EPREFIX}/usr" LIBDIR="${EPREFIX}"/usr/$(get_libdir) install
	if use tools; then
		emake -C apps DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	fi

	einstalldocs
}
