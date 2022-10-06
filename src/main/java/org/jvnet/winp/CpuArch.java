package org.jvnet.winp;

public enum CpuArch {
    X86(32), X86_64(64), ARM64(64), OTHER(0), UNKNOWN(0);

    /**
     * Machine word size, in bits.
     */
    public final int width;

    CpuArch(int width) {
        if (width == 0) {
            try {
                width = Integer.parseInt(System.getProperty("sun.arch.data.model", "32"));
            } catch (NumberFormatException ignored) {
            }
        }
        this.width = width;
    }

    public static final CpuArch CURRENT = fromString(System.getProperty("os.arch"));

    public static CpuArch fromString(String arch) {
        if ("x86_64".equals(arch) || "amd64".equals(arch)) return X86_64;
        if ("i386".equals(arch) || "x86".equals(arch)) return X86;
        if ("aarch64".equals(arch) || "arm64".equals(arch)) return ARM64;
        return arch == null || arch.trim().isEmpty() ? UNKNOWN : OTHER;
    }
}
