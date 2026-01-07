clean:
    just rm zig-out
    just rm .zig-cache
    just rm .claude

rm pattern:
    @find . -name "{{pattern}}" -type d -prune -exec rm -rf {} + 2>/dev/null || true

build:
    zig build

test:
    zig build test --summary all

run:
    cd example && zig build run

fmt:
    zig fmt --check .

ci: fmt build test run
