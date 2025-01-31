; extends
(call_expression
  function: (selector_expression 
    field: (field_identifier) @_id
  )
  arguments: (argument_list (
    (_)?
    .
    [
      (raw_string_literal (raw_string_literal_content) @injection.content)
      (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
    ])
  )
  (#any-of? @_id 
    "QueryRow"
    "Query"
    "Exec"
  )
  ;(#set! injection.include-children)
  (#set! injection.language "sql")
)
