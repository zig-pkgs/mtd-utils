const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const t = target.result;

    const config_h = b.addConfigHeader(
        .{
            .style = .{ .autoconf_undef = b.path("upstream/include/config.h.in") },
            .include_path = "config.h",
        },
        .{
            .HAVE_CLOCK_GETTIME = true,
            .HAVE_EXECINFO_H = if (t.abi.isGnu()) true else null,
            .HAVE_INTTYPES_H = true,
            .HAVE_OPENSSL_RAND_H = true,
            .HAVE_PTHREAD = true,
            .HAVE_PTHREAD_PRIO_INHERIT = true,

            .HAVE_SELINUX_LABEL_H = null,
            .HAVE_SELINUX_SELINUX_H = null,

            .HAVE_STDINT_H = true,
            .HAVE_STDIO_H = true,
            .HAVE_STDLIB_H = true,
            .HAVE_STRINGS_H = true,
            .HAVE_STRING_H = true,
            .HAVE_SYS_ACL_H = true,
            .HAVE_SYS_RANDOM_H = true,
            .HAVE_SYS_STAT_H = true,
            .HAVE_SYS_TYPES_H = true,
            .HAVE_SYS_XATTR_H = true,
            .HAVE_UNISTD_H = true,

            .PACKAGE = "mtd-utils",
            .PACKAGE_BUGREPORT = "linux-mtd@lists.infradead.org",
            .PACKAGE_NAME = "mtd-utils",
            .PACKAGE_STRING = "mtd-utils 2.3.1",
            .PACKAGE_TARNAME = "mtd-utils",
            .PACKAGE_URL = "",
            .PACKAGE_VERSION = "2.3.1",

            .PTHREAD_CREATE_JOINABLE = null,

            .SIZEOF_LOFF_T = 8,
            .SIZEOF_OFF_T = 8,

            .STDC_HEADERS = true,
            .TESTBINDIR = "/usr/local/libexec/mtd-utils",
            .VERSION = "2.3.1",

            ._FILE_OFFSET_BITS = null,
            ._LARGE_FILES = null,
            ._TIME_BITS = null,
            .__MINGW_USE_VC2005_COMPAT = null,
        },
    );

    const lzo_dep = b.dependency("lzo", .{
        .target = target,
        .optimize = optimize,
    });

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });

    const util_linux_dep = b.dependency("util_linux", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "common",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    lib.root_module.addConfigHeader(config_h);
    lib.root_module.addCMacro("_GNU_SOURCE", "");
    lib.root_module.addCMacro("WITH_LZO", "");
    lib.root_module.addCMacro("WITH_ZLIB", "");
    lib.root_module.addCSourceFiles(.{
        .root = b.path("upstream/lib"),
        .files = &lib_src,
        .flags = &.{"-includeconfig.h"},
    });
    lib.root_module.addCSourceFiles(.{
        .root = b.path("upstream/ubifs-utils"),
        .files = &ubifs_utils_src,
        .flags = &.{"-includeconfig.h"},
    });
    lib.root_module.addIncludePath(b.path("upstream/include"));
    lib.root_module.addIncludePath(b.path("upstream/ubifs-utils/common"));
    lib.root_module.addIncludePath(b.path("upstream/ubifs-utils/libubifs"));
    lib.installHeadersDirectory(b.path("upstream/lib"), "", .{});
    lib.installHeadersDirectory(b.path("upstream/ubifs-utils/common"), "", .{});
    lib.installHeadersDirectory(b.path("upstream/ubifs-utils/libubifs"), "", .{});
    b.installArtifact(lib);

    const ubinize = b.addExecutable(.{
        .name = "ubinize",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    ubinize.root_module.addConfigHeader(config_h);
    ubinize.root_module.addCMacro("_GNU_SOURCE", "");
    ubinize.root_module.linkLibrary(lib);
    ubinize.root_module.addCSourceFile(.{
        .file = b.path("upstream/ubi-utils/ubinize.c"),
        .flags = &.{"-includeconfig.h"},
    });
    ubinize.root_module.addIncludePath(b.path("upstream/include"));
    b.installArtifact(ubinize);

    const mkfs_ubifs = b.addExecutable(.{
        .name = "mkfs.ubifs",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    mkfs_ubifs.root_module.addConfigHeader(config_h);
    mkfs_ubifs.root_module.addCMacro("_GNU_SOURCE", "");
    mkfs_ubifs.root_module.addCMacro("WITH_LZO", "");
    mkfs_ubifs.root_module.addCMacro("WITH_ZLIB", "");
    mkfs_ubifs.root_module.linkLibrary(lib);
    mkfs_ubifs.root_module.linkLibrary(lzo_dep.artifact("lzo"));
    mkfs_ubifs.root_module.linkLibrary(zlib_dep.artifact("z"));
    mkfs_ubifs.root_module.linkLibrary(util_linux_dep.artifact("uuid"));
    mkfs_ubifs.root_module.addCSourceFile(.{
        .file = b.path("upstream/ubifs-utils/mkfs.ubifs/mkfs.ubifs.c"),
        .flags = &.{"-includeconfig.h"},
    });
    mkfs_ubifs.root_module.addIncludePath(b.path("upstream/include"));
    b.installArtifact(mkfs_ubifs);

    const libmkfs_ubifs = b.addLibrary(.{
        .name = "mkfs_ubifs",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    libmkfs_ubifs.root_module.addConfigHeader(config_h);
    libmkfs_ubifs.root_module.addCMacro("_GNU_SOURCE", "");
    libmkfs_ubifs.root_module.addCMacro("WITH_LZO", "");
    libmkfs_ubifs.root_module.addCMacro("WITH_ZLIB", "");
    libmkfs_ubifs.root_module.linkLibrary(lib);
    libmkfs_ubifs.root_module.linkLibrary(lzo_dep.artifact("lzo"));
    libmkfs_ubifs.root_module.linkLibrary(zlib_dep.artifact("z"));
    libmkfs_ubifs.root_module.linkLibrary(util_linux_dep.artifact("uuid"));
    libmkfs_ubifs.root_module.addCSourceFile(.{
        .file = b.path("upstream/ubifs-utils/mkfs.ubifs/mkfs.ubifs.c"),
        .flags = &.{
            "-includeconfig.h",
            "-Dmain=mkfs_ubifs_main",
        },
    });
    libmkfs_ubifs.root_module.addIncludePath(b.path("upstream/include"));
    b.installArtifact(libmkfs_ubifs);
}

const lib_src = [_][]const u8{
    "libmtd.c",
    "libfec.c",
    "common.c",
    "list_sort.c",
    "rbtree.c",
    "libcrc32.c",
    "libmtd_legacy.c",

    "execinfo.c",

    "libubi.c",

    "libubigen.c",

    "libscan.c",

    "libiniparser.c",
    "dictionary.c",
};

const ubifs_utils_src = [_][]const u8{
    "common/bitops.c",
    "common/kmem.c",
    "common/sort.c",
    "common/crc16.c",
    "common/compr.c",
    "common/hashtable/hashtable.c",
    "common/hashtable/hashtable_itr.c",
    "common/devtable.c",
    "common/hexdump.c",

    "libubifs/io.c",
    "libubifs/sb.c",
    "libubifs/super.c",
    "libubifs/master.c",
    "libubifs/debug.c",
    "libubifs/scan.c",
    "libubifs/find.c",
    "libubifs/dir.c",
    "libubifs/budget.c",
    "libubifs/journal.c",
    "libubifs/gc.c",
    "libubifs/lpt.c",
    "libubifs/lpt_commit.c",
    "libubifs/lprops.c",
    "libubifs/tnc_misc.c",
    "libubifs/tnc.c",
    "libubifs/tnc_commit.c",
    "libubifs/commit.c",
    "libubifs/orphan.c",
    "libubifs/log.c",
    "libubifs/replay.c",
    "libubifs/recovery.c",
};
