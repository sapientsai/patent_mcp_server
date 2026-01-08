# USPTO Patent MCP Server
# Native HTTP transport via FastMCP

FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Copy application files
COPY . /app/

# Install Python dependencies
RUN uv sync

# Create directories for logs
RUN mkdir -p /app/logs

# Set environment for HTTP transport
ENV MCP_TRANSPORT=http

# Expose port
EXPOSE 8000

# Health check - MCP streamable HTTP responds to POST with initialize
# Note: endpoint is /mcp (no trailing slash) to avoid 307 redirect
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -sf -X POST http://localhost:8000/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"healthcheck","version":"1.0"}}}' | grep -q "protocolVersion" || exit 1

# Run the MCP server
CMD ["uv", "run", "patent-mcp-server"]