;; extends

((string_literal
  (string_content) @injection.content)
  (#set! injection.language "sql")
  (#lua-match? @injection.content "^%s*([Ss][Ee][Ll][Ee][Cc][Tt]|[Ww][Ii][Tt][Hh]|[Bb][Ee][Gg][Ii][Nn]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee]|[Cc][Rr][Ee][Aa][Tt][Ee]|[Aa][Ll][Tt][Ee][Rr]|[Dd][Rr][Oo][Pp])%s+"))

((raw_string_literal
  (string_content) @injection.content)
  (#set! injection.language "sql")
  (#lua-match? @injection.content "^%s*([Ss][Ee][Ll][Ee][Cc][Tt]|[Ww][Ii][Tt][Hh]|[Bb][Ee][Gg][Ii][Nn]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee]|[Cc][Rr][Ee][Aa][Tt][Ee]|[Aa][Ll][Tt][Ee][Rr]|[Dd][Rr][Oo][Pp])%s+"))
