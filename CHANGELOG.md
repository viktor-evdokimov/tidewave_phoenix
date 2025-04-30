# Changelog

## 0.1.1 (2025-04-30)

* Enhancements
  * evaluate commands in a separate process with timeout
  * handle clients that are trying to establish a connection using the new Streamable transport by replying with 405 (Method not allowed)
    as documented in the MCP specification. (we will work on adding support for the new Streamable transport in the future!)
  * small improvements to the documentation and tool descriptions

## 0.1.0 (2025-04-29)

Initial release.