# USPTO Patent MCP Server
# Native HTTP transport via FastMCP

FROM python:3.11-slim

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

# Health check - verify server is listening without creating MCP sessions
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -sf -o /dev/null -w '%{http_code}' http://localhost:8000/mcp/ | grep -q '[0-9]' || exit 1

# Run the MCP server
CMD ["uv", "run", "patent-mcp-server"]