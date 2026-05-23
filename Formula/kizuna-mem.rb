class KizunaMem < Formula
  desc "Temporal graph-based memory engine for AI agents"
  homepage "https://kizuna-mem.app"
  version "0.1.0"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://github.com/deep-thinking-lab/kizuna-dream/releases/download/v#{version}/kizuna-mem-#{version}-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER_SHA256"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/deep-thinking-lab/kizuna-dream/releases/download/v#{version}/kizuna-mem-#{version}-linux-x86_64.tar.gz"
      sha256 "PLACEHOLDER_SHA256"
    end
  end

  def install
    bin.install "kizuna-mem"
    bin.install "kizuna-mem-sidecar"
  end

  def caveats
    <<~EOS
      To start Kizuna-Mem:
        kizuna-mem-sidecar &
        KIZUNA_SERVER_PORT=50051 kizuna-mem

      Then connect your AI agent to http://localhost:50051

      For MCP integration (Claude, Cursor, NanoClaw):
        npx -y @kizuna-mem/mcp-server
    EOS
  end

  service do
    run [opt_bin/"kizuna-mem"]
    environment_variables KIZUNA_SERVER_PORT: "50051"
    keep_alive true
    log_path var/"log/kizuna-mem.log"
    error_log_path var/"log/kizuna-mem-error.log"
  end

  test do
    assert_predicate bin/"kizuna-mem", :exist?
    assert_predicate bin/"kizuna-mem-sidecar", :exist?
  end
end
